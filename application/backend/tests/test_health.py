from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def test_root_endpoint():
    response = client.get("/")

    assert response.status_code == 200
    assert response.json()["status"] == "running"


def test_health_endpoint():
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json()["status"] == "healthy"


def test_services_endpoint():
    response = client.get("/services")

    assert response.status_code == 200
    assert response.json()["services"][0]["name"] == "backend-api"


def test_create_deployment():
    response = client.post(
        "/deployments",
        json={
            "service": "backend-api",
            "environment": "dev",
            "version": "1.0.0",
            "deployed_by": "yuvraj",
        },
    )

    assert response.status_code == 200
    assert response.json()["service"] == "backend-api"
    assert response.json()["environment"] == "dev"
    assert response.json()["status"] == "successful"


def test_invalid_environment():
    response = client.post(
        "/deployments",
        json={
            "service": "backend-api",
            "environment": "testing",
            "version": "1.0.0",
            "deployed_by": "yuvraj",
        },
    )

    assert response.status_code == 400
    assert response.json()["detail"] == (
        "Environment must be dev, staging or production"
    )