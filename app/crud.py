# app/crud.py
from sqlalchemy.orm import Session
from . import models, auth # CORREGIDO: Importación relativa de auth
from .models import Package, Agent, Delivery, PackageStatus # CORREGIDO: Importación relativa para clases específicas

def get_agent_by_username(db: Session, username: str):
    return db.query(Agent).filter(Agent.username == username).first()

def create_agent(db: Session, username: str, password: str, full_name: str = None):
    hashed = auth.hash_password(password)
    agent = Agent(username=username, password_hash=hashed, full_name=full_name)
    db.add(agent)
    db.commit()
    db.refresh(agent)
    return agent

def get_packages_for_agent(db: Session, agent_id: int):
    return db.query(Package).filter(Package.assigned_agent_id == agent_id).all()

def get_package_by_uid(db: Session, package_uid: str):
    return db.query(Package).filter(Package.package_uid == package_uid).first()

def get_package(db: Session, package_id: int):
    return db.query(Package).filter(Package.id == package_id).first()

def mark_delivered(db: Session, package_id: int, agent_id: int, photo_path: str, lat: float, lon: float, notes: str = None):
    # create delivery record
    delivery = Delivery(package_id=package_id, agent_id=agent_id, photo_path=photo_path, latitude=lat, longitude=lon, notes=notes)
    db.add(delivery)
    # update package status
    pkg = get_package(db, package_id)
    if pkg:
        pkg.status = PackageStatus.delivered
    db.commit()
    db.refresh(delivery)
    return delivery