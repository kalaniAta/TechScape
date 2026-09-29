"""
TechScape Relational Database Session and Engine Management.
Configures SQLite with PRAGMA foreign_keys = ON and transaction lifecycle.
"""

import os
from contextlib import contextmanager
from typing import Generator, Optional

from sqlalchemy import Engine, create_engine, event
from sqlalchemy.orm import Session, sessionmaker

from python.db.models import Base

# Default database location
DEFAULT_DB_PATH = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "..", "data", "techscape.db")
)


def configure_sqlite_pragmas(dbapi_connection, connection_record):
    """Enforces SQLite foreign key constraints on every new connection."""
    cursor = dbapi_connection.cursor()
    cursor.execute("PRAGMA foreign_keys = ON;")
    cursor.close()


def get_engine(db_path: Optional[str] = None, echo: bool = False) -> Engine:
    """
    Creates and returns a SQLAlchemy Engine configured for SQLite with foreign keys enabled.
    """
    path = db_path or DEFAULT_DB_PATH
    os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
    engine_url = f"sqlite:///{path}"
    engine = create_engine(engine_url, echo=echo)

    # Attach foreign key pragma listener
    event.listen(engine, "connect", configure_sqlite_pragmas)
    return engine


def get_session_factory(engine: Optional[Engine] = None) -> sessionmaker[Session]:
    """Returns a thread-safe sessionmaker bound to the engine."""
    eng = engine or get_engine()
    return sessionmaker(bind=eng, autoflush=False, expire_on_commit=False)


@contextmanager
def get_session(engine: Optional[Engine] = None) -> Generator[Session, None, None]:
    """
    Context manager providing transactional session scope.
    Commits changes automatically, or rolls back if an exception is raised.
    """
    factory = get_session_factory(engine)
    session = factory()
    try:
        yield session
        if session.is_active:
            session.commit()
    except Exception:
        if session.is_active:
            session.rollback()
        raise
    finally:
        session.close()


def init_db(engine: Optional[Engine] = None) -> None:
    """Creates all database tables defined in the metadata."""
    eng = engine or get_engine()
    Base.metadata.create_all(bind=eng)
