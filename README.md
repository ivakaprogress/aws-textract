# AWS Textract Project for Extracting Info from PDF and Uploading it as JSON File in DynamoDB

This project uses AWS Textract to extract information from PDF files and store the extracted data as JSON files in DynamoDB. The process involves two Lambda functions: one to create and manage the Textract job and another to process the Textract response and store the data in DynamoDB.

## Overview

1. **First Lambda Function (Create Textract Job)**: This function initiates an Amazon Textract job with the details of the uploaded PDF file.
2. **Amazon Textract**: Textract performs Optical Character Recognition (OCR) on the PDF file.
3. **Amazon SNS**: Textract sends a notification to Amazon Simple Notification Service (SNS) upon job completion.
4. **Second Lambda Function (Process Textract Response)**: This function is triggered by the SNS notification. It processes the Textract response and stores the extracted data in DynamoDB as a JSON file.

## Architecture

1. **Upload PDF to S3 Bucket**: The process starts by uploading a PDF file to a specified S3 bucket.
2. **Trigger First Lambda Function**: The upload triggers the first Lambda function, which creates a Textract job.
3. **Textract OCR**: Textract processes the PDF file and extracts text and data.
4. **SNS Notification**: Upon completion, Textract sends a notification to SNS.
5. **Trigger Second Lambda Function**: The SNS notification triggers the second Lambda function.
6. **Process Response and Store in DynamoDB**: The second Lambda function processes the Textract response and stores the extracted data in DynamoDB as JSON.
7. **Validation Bot**: Use the extracted key-value pairs from the OCR to create a validation bot that can determine the validity of a document based on user-defined criteria.
