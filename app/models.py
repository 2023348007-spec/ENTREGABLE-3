# app/models.py
from sqlalchemy import Column, Integer, String, TIMESTAMP, Enum, ForeignKey, DECIMAL, Text
from sqlalchemy.sql import func
from .database import Base # CORREGIDO: Importación relativa de Base
import enum 

class PackageStatus(str, enum.Enum):
    assigned = "assigned"
    in_transit = "in_transit"
    delivered = "delivered"

class Agent(Base):
    __tablename__ = "agents"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(100), unique=True, index=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    full_name = Column(String(150))
    created_at = Column(TIMESTAMP, server_default=func.now())

class Package(Base):
    __tablename__ = "packages"
    id = Column(Integer, primary_key=True, index=True)
    package_uid = Column(String(100), unique=True, nullable=False)
    address = Column(String(255), nullable=False)
    city = Column(String(100))
    state = Column(String(100))
    postal_code = Column(String(20))
    status = Column(Enum(PackageStatus), default=PackageStatus.assigned)
    assigned_agent_id = Column(Integer, ForeignKey("agents.id"), nullable=True)
    created_at = Column(TIMESTAMP, server_default=func.now())

class Delivery(Base):
    __tablename__ = "deliveries"
    id = Column(Integer, primary_key=True, index=True)
    package_id = Column(Integer, ForeignKey("packages.id"), nullable=False)
    agent_id = Column(Integer, ForeignKey("agents.id"), nullable=False)
    photo_path = Column(String(255))
    latitude = Column(DECIMAL(10,7))
    longitude = Column(DECIMAL(10,7))
    delivered_at = Column(TIMESTAMP, server_default=func.now())
    notes = Column(Text)