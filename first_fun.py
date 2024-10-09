import json
import boto3
import pandas as pd
import pyarrow.parquet as pq
import pyarrow as pa
from io import BytesIO

s3 = boto3.client('s3')

def convert_to_parquet(df):
    """
    Convert a pandas DataFrame to Parquet format and return as bytes.
    """
    table = pa.Table.from_pandas(df)
    buffer = BytesIO()
    pq.write_table(table, buffer)
    buffer.seek(0)
    return buffer.getvalue()

def lambda_handler(event, context):
    source_bucket = event['Records'][0]['s3']['bucket']['name']
    source_key = event['Records'][0]['s3']['object']['key']
    
    print(f"Bucket: {source_bucket}")
    print(f"Key: {source_key}")
    
    target_bucket = 'terraformsecondbucket'
    target_folder = 'Files/'
    target_key = target_folder + source_key.rsplit('.', 1)[0] + '.parquet'
    
    if source_key.endswith('.parquet'):
        # Directly copy the parquet file
        copy_source = {'Bucket': source_bucket, 'Key': source_key}
        s3.copy_object(CopySource=copy_source, Bucket=target_bucket, Key=target_key)
        return {
            'statusCode': 200,
            'body': json.dumps(f"File {source_key} copied to {target_bucket}/{target_key}")
        }
    else:
        
        obj = s3.get_object(Bucket=source_bucket, Key=source_key)
        file_content = obj['Body'].read()
        
        if source_key.endswith('.json'):
            df = pd.read_json(BytesIO(file_content))
        elif source_key.endswith('.csv'):
            df = pd.read_csv(BytesIO(file_content))
        else:
            raise ValueError(f"Unsupported file type: {source_key}")
            
        parquet_content = convert_to_parquet(df)
        
        s3.put_object(Bucket=target_bucket, Key=target_key, Body=parquet_content)
        
        return {
            'statusCode': 200,
            'body': json.dumps(f"File {source_key} converted and uploaded to {target_bucket}/{target_key}")
        }
