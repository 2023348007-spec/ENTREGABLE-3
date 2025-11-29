# app/schemas.py (Corregido para Pydantic V2)
from pydantic import BaseModel, ConfigDict # Importar ConfigDict
from typing import Optional
from datetime import datetime

class AgentCreate(BaseModel):
    username: str
    password: str
    full_name: Optional[str] = None

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None

class PackageOut(BaseModel):
    id: int
    package_uid: str
    address: str
    city: Optional[str]
    state: Optional[str]
    postal_code: Optional[str]
    status: str

    model_config = ConfigDict(from_attributes=True) # CORREGIDO para Pydantic V2

class DeliveryCreate(BaseModel):
    package_id: int
    latitude: float
    longitude: float
    notes: Optional[str] = None