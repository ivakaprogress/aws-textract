import uuid
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


class Parse:
    def __init__(self, page, get_kv, get_signatures):
        self.response = page
        self.word_map = {}
        self.table_page_map = {}
        self.key_map = []
        self.value_map = {}
        self.final_map_list = []
        self.line_text = {}
        self.get_kv = get_kv
        self.get_signatures = get_signatures

    def extract_text(self, extract_by="LINE"):
        for block in self.response:
            if block["BlockType"] == extract_by:
                page_key = f'page_{block["Page"]}'
                if page_key in self.line_text.keys():
                    self.line_text[page_key].append(block["Text"])
                else:
                    self.line_text[page_key] = [block["Text"]]
        return self.line_text

    def map_word_id(self):
        for block in self.response:
            if block["BlockType"] == "WORD":
                self.word_map[block["Id"]] = block["Text"]
            if block["BlockType"] == "SELECTION_ELEMENT":
                self.word_map[block["Id"]] = block["SelectionStatus"]
            if block["BlockType"] == "SIGNATURE":
                self.word_map[block["Id"]] = ""

    def get_key_map(self):
        for block in self.response:

            if block["BlockType"] == "KEY_VALUE_SET" and "KEY" in block["EntityTypes"]:
                for relation in block["Relationships"]:
                    if relation["Type"] == "VALUE":
                        value_id = relation["Ids"]
                    if relation["Type"] == "CHILD":
                        v = " ".join([self.word_map[i] for i in relation["Ids"]])
                        self.key_map.append([v, value_id])

    def get_value_map(self):
        for block in self.response:
            if (
                    block["BlockType"] == "KEY_VALUE_SET"
                    and "VALUE" in block["EntityTypes"]
            ):
                if "Relationships" in block:
                    for relation in block["Relationships"]:
                        if relation["Type"] == "CHILD":
                            v = " ".join([self.word_map[i] for i in relation["Ids"]])
                            self.value_map[block["Id"]] = v
                else:
                    self.value_map[block["Id"]] = "VALUE_NOT_FOUND"

    def get_kv_map(self):
        for i in self.key_map:
            self.final_map_list.append(
                [i[0], "".join(["".join(self.value_map[k]) for k in i[1]])]
            )

        return self.final_map_list

    def get_signature_info(self):
        page, signature, confidence = [], [], []
        temp_counter = 0
        for e, block in enumerate(self.response):
            if block["BlockType"] == "SIGNATURE":
                page.append(block.get("Page"))
                signature.append(f"Signature {temp_counter + 1}")
                confidence.append(block.get("Confidence"))
                temp_counter += 1
        return (page, signature, confidence)

    def process_response(self):
        final_map = None

        logging.info("Mapping Id with word")
        self.map_word_id()

        if self.get_kv:
            logging.info("Extracting Key-Value pairs")
            self.get_key_map()
            self.get_value_map()
            final_map = self.get_kv_map()

        if self.get_signatures:
            logging.info("Extracting signature information")
            sign_info = self.get_signature_info()

        return final_map, sign_info