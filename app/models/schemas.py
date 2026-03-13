from pydantic import BaseModel

class BirthCreate(BaseModel):
    reference_id: str
    full_name: str
    birth_date: str
    parent_phone: str
    language: str

    class Config:
        from_attributes = True