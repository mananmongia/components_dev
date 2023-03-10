import requests, json, os
from datetime import date
from requests_toolbelt import MultipartEncoder



def dd_setup():
    global DD_URL
    DD_URL = os.environ["dd_url"]

    global DD_TOKEN
    DD_TOKEN = auth(os.environ["dd_username"], os.environ["dd_password"])

    global DD_PRODUCT_NAME
    DD_PRODUCT_NAME = os.environ["dd_product_name"]

    global DD_PROD_DESC
    DD_PROD_DESC = os.environ["dd_product_desc"]

    global result_file
    result_file = os.listdir("/results")
    for i in result_file:
        if i.endswith(".conf"):
            result_file.remove(i)

    global pipeline_no
    pipeline_no = os.environ["pno"]

    global DD_SCANTYPE
    DD_SCANTYPE = result_file[0].split("-")[1].split(".")[0]
    print(f'Scan Type: {DD_SCANTYPE}')

    global ENG_NAME
    ENG_NAME = "Pipeline No " + str(pipeline_no)
    print(f'ENG_NAME: {ENG_NAME}')


def auth(dd_username, dd_password):
    # Returns Authentication Token
    r = requests.post(
        DD_URL + "/api/v2/api-token-auth/",
        data=json.dumps({"username": dd_username, "password": dd_password}),
        headers={"Content-Type": "application/json"},
    ) 
    print(f'Auth Token Generated: {r}')
    return r.content.decode("UTF-8").split('"')[3]


def get_prod_id():
    # Get Product ID of exixting product
    r = requests.get(
        DD_URL + "/api/v2/products", headers={"Authorization": "Token " + DD_TOKEN}
    )
    for product in r.json()["results"]:
        if product["name"] == DD_PRODUCT_NAME:
            print(f'Product Exists on DefectDojo: {r}')
            return product["id"]
    return None


def get_eng_id():
    r = requests.get(
        DD_URL + "/api/v2/engagements", headers={"Authorization": "Token " + DD_TOKEN}
    )
    for eng in r.json()["results"]:
        if eng["name"] == ENG_NAME:
            print(f'Engagement Exists inside product on DefectDojo: {r}')
            global ENG_ID
            ENG_ID = str(eng["id"])
            #Update global variable for eng_ip
            return eng["id"]
    return None


def create_prod():
    fields = {
        "name": DD_PRODUCT_NAME,
        "product_name": DD_PRODUCT_NAME,
        "prod_type": "1",
        "description": DD_PROD_DESC,
    }
    r = requests.post(
        DD_URL + "/api/v2/products/",
        data=json.dumps(fields),
        headers={
            "Content-Type": "application/json",
            "Authorization": "Token " + DD_TOKEN,
        },
    )
    print(f'Product Created in DefectDojo: {r}')

    return r.json()["id"]


def create_eng_type():
    today = date.today()
    t_date = today.strftime("%Y-%m-%d")
    r = requests.post(
        DD_URL + "/api/v2/engagements/",
        data=json.dumps(
            {
                "name": ENG_NAME,
                "product": str(get_prod_id()),
                "engagement_type": "CI/CD",
                "target_start": str(t_date),
                "prod_type": "1",
                "target_end": str(t_date),
                "description": "Pipeline no: " + ENG_NAME + " Scans",
            }
        ),
        headers={
            "Content-Type": "application/json",
            "Authorization": "Token " + DD_TOKEN,
        },
    )


def upload_scan():

    mp_encoder = MultipartEncoder(
        fields={
            "scan_type": DD_SCANTYPE,
            "product_name": DD_PRODUCT_NAME,
            "engagement_name": ENG_NAME,
            "name": ENG_NAME,
            "engagement": ENG_ID,
            "file": (
                result_file[0],
                open("/results/" + result_file[0], "rb"),
                "application/json",
            ),
        }
    )
    r = requests.post(
        DD_URL + "/api/v2/import-scan/",
        data=mp_encoder,
        headers={
            "Content-Type": mp_encoder.content_type,
            "Authorization": "Token " + DD_TOKEN,
        },
    )
    print(f'Results pushed?: {r}')


if __name__ == "__main__":
    dd_setup()
    if get_prod_id():
        if get_eng_id():
            print("Product and Engagement Exists in DefectDojo\nUploading Scan Report")
            upload_scan()
        else:
            create_eng_type() 
            upload_scan()
    else:
        create_prod()
        create_eng_type() 
        upload_scan()

