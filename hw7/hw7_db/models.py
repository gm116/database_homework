from sqlalchemy import Column, Integer, String, Date, ForeignKey, CheckConstraint, Float
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship

Base = declarative_base()

class Country(Base):
    __tablename__ = 'countries'

    country_id = Column(String(3), primary_key=True, unique=True)
    name = Column(String(40), nullable=False)
    area_sqkm = Column(Integer)
    population = Column(Integer)

class Olympic(Base):
    __tablename__ = 'olympics'

    olympic_id = Column(String(7), primary_key=True, unique=True)
    country_id = Column(String(3), ForeignKey('countries.country_id'))
    city = Column(String(50))
    year = Column(Integer)
    startdate = Column(Date)
    enddate = Column(Date)

    country = relationship("Country", back_populates="olympics")

class Player(Base):
    __tablename__ = 'players'

    player_id = Column(String(10), primary_key=True, unique=True)
    name = Column(String(40), nullable=False)
    country_id = Column(String(3), ForeignKey('countries.country_id'))
    birthdate = Column(Date)

    country = relationship("Country", back_populates="players")

class Event(Base):
    __tablename__ = 'events'

    event_id = Column(String(7), primary_key=True, unique=True)
    name = Column(String(40), nullable=False)
    eventtype = Column(String(20))
    olympic_id = Column(String(7), ForeignKey('olympics.olympic_id'))
    is_team_event = Column(Integer, CheckConstraint('is_team_event IN (0, 1)'))
    num_players_in_team = Column(Integer)
    result_noted_in = Column(String(100))

    olympic = relationship("Olympic", back_populates="events")

class Result(Base):
    __tablename__ = 'results'

    event_id = Column(String(7), ForeignKey('events.event_id'), primary_key=True)
    player_id = Column(String(10), ForeignKey('players.player_id'), primary_key=True)
    medal = Column(String(7))
    result = Column(Float)

    event = relationship("Event", back_populates="results")
    player = relationship("Player", back_populates="results")

# Связи между моделями
Country.olympics = relationship("Olympic", order_by=Olympic.olympic_id, back_populates="country")
Country.players = relationship("Player", order_by=Player.player_id, back_populates="country")
Olympic.events = relationship("Event", order_by=Event.event_id, back_populates="olympic")
Event.results = relationship("Result", order_by=Result.event_id, back_populates="event")
Player.results = relationship("Result", order_by=Result.player_id, back_populates="player")
