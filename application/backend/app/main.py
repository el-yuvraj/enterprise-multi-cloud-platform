from datetime import datetime, timezone
from typing import Optional

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel


app = FastAPI(
    title="Enterprise Multi-Cloud Platform",
    description="Service and deployment management API",
    version="1.0.0",
)


# -------------------------
# Data Models
# -------------------------

class DeploymentRequest(BaseModel):
    service: str
    environment: str
    version: str
    deployed_by: str


class Deployment(BaseModel):
    id: int
    service: str
    environment: str
    version: str
    deployed_by: str
    status: str
    created_at: str


# -------------------------
# Temporary application data
# -------------------------

deployments = []

next_deployment_id = 1


# -------------------------
# Basic endpoints
# -------------------------

@app.get("/")
def root():
    return {
        "application": "enterprise-multi-cloud-platform",
        "version": "1.0.0",
        "status": "running",
    }


@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }


# -------------------------
# Service endpoint
# -------------------------

@app.get("/services")
def get_services():
    return {
        "services": [
            {
                "name": "backend-api",
                "status": "running",
                "version": "1.0.0",
            }
        ]
    }


# -------------------------
# Deployment endpoints
# -------------------------

@app.post("/deployments", response_model=Deployment)
def create_deployment(request: DeploymentRequest):
    global next_deployment_id

    if request.environment not in ["dev", "staging", "production"]:
        raise HTTPException(
            status_code=400,
            detail="Environment must be dev, staging or production",
        )

    deployment = Deployment(
        id=next_deployment_id,
        service=request.service,
        environment=request.environment,
        version=request.version,
        deployed_by=request.deployed_by,
        status="successful",
        created_at=datetime.now(timezone.utc).isoformat(),
    )

    deployments.append(deployment)
    next_deployment_id += 1

    return deployment


@app.get("/deployments")
def get_deployments():
    return {
        "count": len(deployments),
        "deployments": deployments,
    }


@app.get("/deployments/{deployment_id}", response_model=Deployment)
def get_deployment(deployment_id: int):
    for deployment in deployments:
        if deployment.id == deployment_id:
            return deployment

    raise HTTPException(
        status_code=404,
        detail="Deployment not found",
    )