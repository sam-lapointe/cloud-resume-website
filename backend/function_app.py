import azure.functions as func
import logging
import json

from update_views import Entity

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

@app.route(route="updateviews")
def updateviews(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    website = req.params.get('website')
    page = req.params.get('page')

    views = Entity(website, page)
    logging.info(entity.entity)
    views.update_views()
    views.update_db()

    return json.dumps({
        "views": views.entity["views"]
    })