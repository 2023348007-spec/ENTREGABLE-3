# app/main.py
import os
from fastapi import FastAPI, Depends, HTTPException, status, UploadFile, File, Form
from fastapi.security import OAuth2PasswordRequestForm, OAuth2PasswordBearer
from sqlalchemy.orm import Session
from .database import SessionLocal, engine 
from . import models, crud, schemas, auth 
from .config import MEDIA_DIR, API_PREFIX
from pathlib import Path
from datetime import timedelta
from fastapi.middleware.cors import CORSMiddleware # <--- IMPORTACIÓN AÑADIDA

models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Paquexpress API")

# <--- BLOQUE DE CORS AÑADIDO ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Permite cualquier origen (solución para desarrollo en web)
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
# -----------------------------

oauth2_scheme = OAuth2PasswordBearer(tokenUrl=f"{API_PREFIX}/token")

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Create a token endpoint (login)
@app.post(f"{API_PREFIX}/token", response_model=schemas.Token)
def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = crud.get_agent_by_username(db, form_data.username)
    if not user or not auth.verify_password(form_data.password, user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Incorrect credentials")
    access_token_expires = timedelta(minutes=60*24)
    access_token = auth.create_access_token(data={"sub": user.username}, expires_delta=access_token_expires)
    return {"access_token": access_token, "token_type": "bearer"}

# Helper to get current user
def get_current_agent(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    payload = auth.decode_token(token)
    if not payload or "sub" not in payload:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid authentication")
    username = payload["sub"]
    agent = crud.get_agent_by_username(db, username)
    if not agent:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Agent not found")
    return agent

# List packages assigned to current agent
@app.get(f"{API_PREFIX}/packages", response_model=list[schemas.PackageOut])
def list_packages(db: Session = Depends(get_db), agent: models.Agent = Depends(get_current_agent)):
    pkgs = crud.get_packages_for_agent(db, agent.id)
    return pkgs

# Endpoint to submit delivery evidence
@app.post(f"{API_PREFIX}/deliver")
async def deliver_package(
    package_id: int = Form(...),
    latitude: float = Form(...),
    longitude: float = Form(...),
    notes: str = Form(None),
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    agent: models.Agent = Depends(get_current_agent)
):
    # Save file
    Path(MEDIA_DIR).mkdir(parents=True, exist_ok=True)
    filename = f"{package_id}_{agent.id}_{file.filename}"
    file_path = os.path.join(MEDIA_DIR, filename)
    with open(file_path, "wb") as f:
        content = await file.read()
        f.write(content)
    # record delivery and update status
    delivery = crud.mark_delivered(db, package_id=package_id, agent_id=agent.id, photo_path=file_path, lat=latitude, lon=longitude, notes=notes)
    return {"detail": "Delivery recorded", "delivery_id": delivery.id}

# Simple endpoint to create an agent (for testing) - in prod restringir
@app.post(f"{API_PREFIX}/agents/create")
def create_agent(a: schemas.AgentCreate, db: Session = Depends(get_db)):
    existing = crud.get_agent_by_username(db, a.username)
    if existing:
        raise HTTPException(status_code=400, detail="Agent exists")
    agent = crud.create_agent(db, username=a.username, password=a.password, full_name=a.full_name)
    return {"id": agent.id, "username": agent.username}