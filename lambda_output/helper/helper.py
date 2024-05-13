import sys
import boto3
import io
import logging
import traceback
import json
from collections import ChainMap
from operator import itemgetter
from .parser import Parse

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def process_error():
    ex_type, ex_value, ex_traceback = sys.exc_info()
    traceback_string = traceback.format_exception(ex_type, ex_value, ex_traceback)
    error_msg = json.dumps(
        {
            "errorType": ex_type.__name__,
            "errorMessage": str(ex_value),
            "stackTrace": traceback_string,
        }
    )
    return error_msg


def upload_to_dynamodb(json_buffer, DYNAMODB, key):
    try:
        dynamodb = boto3.resource('dynamodb')
        table = dynamodb.Table(DYNAMODB)
        table.put_item(
            Item={
                'senger': key,
                'data': json_buffer.getvalue()
            }
        )
    except Exception as e:
        logger.error(f"Failed to upload {key} to DynamoDB. Error: {e}")
        error_msg = process_error()
        raise Exception(error_msg)


# def save_sign_csv(sign_info, job_id, DYNAMODB):
#     key = f"signature-{job_id}/signature_info.csv"
#     df = pd.DataFrame()
#     df["page_no"] = sign_info[0]
#     df["signature"] = sign_info[1]
#     df["confidence"] = sign_info[2]
#     csv_buffer = io.StringIO()
#     df.to_csv(csv_buffer)
#     upload_to_dynamodb(csv_buffer, DYNAMODB, key)


def extract_kv(final_map):
    keys, values = [], []
    for i in final_map:
        for k, v in i.items():
            keys.append(k)
            values.append(v)
    return keys, values


# def save_kv_csv(keys, values, job_id, DYNAMODB):
#     key = f"kv-{job_id}/key_value.csv"
#     df = pd.DataFrame()
#     df["Keys"] = keys
#     df["Values"] = values
#     csv_buffer = io.StringIO()
#     df.to_csv(csv_buffer)
#     upload_to_dynamodb(csv_buffer, DYNAMODB, key)


def extract_kv_text(text):
    keys, values = [], []
    for k, v in text.items():
        keys.append(k)
        values.append(v)
    return keys, values


def map_word_id(response):
    word_map = {}
    for block in response["Blocks"]:
        if block["BlockType"] == "WORD":
            word_map[block["Id"]] = block["Text"]
        if block["BlockType"] == "SELECTION_ELEMENT":
            word_map[block["Id"]] = block["SelectionStatus"]
    return word_map


def save_json_to_dynamodb(keys, values, sign_info, job_id, DYNAMODB):
    key = f"Job-{job_id}-data.json"

    # Create dictionary for key-value pairs
    kv_dict = dict(zip(keys, values))

    # Create dictionary for signature info
    if sign_info and len(sign_info) >= 3 and sign_info[0] and sign_info[1] and sign_info[2]:
        sign_dict = {"page_no": sign_info[0][0], "signature": sign_info[1][0], "confidence": sign_info[2][0]}
    else:
        # Handle the case when no signature is detected or sign_info doesn't have the expected structure
        sign_dict = {"page_no": "N/A", "signature": "N/A", "confidence": "N/A"}

    if 'Unterschrift' in kv_dict:
        kv_dict['Unterschrift'] = sign_dict['signature']
    elif 'Unterschrift:' in kv_dict:
        kv_dict['Unterschrift:'] = sign_dict['signature']

    # Combine dictionaries
    data_dict = dict(ChainMap(kv_dict, sign_dict))

    # Save data to JSON buffer
    json_buffer = io.StringIO()
    json.dump(data_dict, json_buffer)
    upload_to_dynamodb(json_buffer, DYNAMODB, key)


def process_response(
        DYNAMODB, job_id, get_kv=True, get_signatures=True
):
    textract = boto3.client("textract")

    response = {}
    pages = []

    logging.info("Fetching response")
    response = textract.get_document_analysis(JobId=job_id)
    pages.append(response)

    nextToken = None
    logging.info("Checking paginated response")
    if "NextToken" in response:
        logging.info("Paginated response found")
        nextToken = response["NextToken"]

    while nextToken:
        response = textract.get_document_analysis(JobId=job_id, NextToken=nextToken)
        pages.append(response)
        nextToken = None
        if "NextToken" in response:
            nextToken = response["NextToken"]

    keys, values = [], []
    text_key, text_value = [], []
    logger.info("Looping through pages & parsing the response")
    pages_block = []
    for page in pages:
        pages_block.extend(page["Blocks"])

    parse = Parse(
        page=pages_block,
        get_kv=get_kv,
        get_signatures=get_signatures,
    )
    final_map, sign = parse.process_response()

    if get_kv or get_signatures:
        keys = list(map(itemgetter(0), final_map))
        values = list(map(itemgetter(1), final_map))
        save_json_to_dynamodb(keys, values, sign, job_id, DYNAMODB)
    logger.info("Parsing completed")
