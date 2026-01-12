from fastapi import FastAPI

import filterV

app = FastAPI()


@app.get("/filter")
def compute_filter():
