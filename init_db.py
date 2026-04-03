from app.core.db import Base, engine
from app.models.birth import Localite, Parent, PreEnregistrement

print("Creating database tables...")
Base.metadata.create_all(bind=engine)
print("Tables created successfully.")
