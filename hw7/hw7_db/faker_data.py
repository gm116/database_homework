from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from faker import Faker
import random
from datetime import date, timedelta
from models import Base, Country, Olympic, Player, Event, Result

engine = create_engine('postgresql://superadmin:superadmin@localhost:5440/olimp')
Session = sessionmaker(bind=engine)
session = Session()

fake = Faker()


def populate_countries(num=10):
    countries = []
    for _ in range(num):
        country = Country(
            country_id=fake.unique.country_code(),
            name=fake.country(),
            area_sqkm=fake.random_int(min=1000, max=500000),
            population=fake.random_int(min=100000, max=100000000)
        )
        countries.append(country)
        session.add(country)
    session.commit()
    return countries


def populate_olympics(countries, num=5):
    olympics = []
    for _ in range(num):
        country = random.choice(countries)
        start_date = fake.date_this_century()
        end_date = start_date + timedelta(days=random.randint(10, 20))

        olympic = Olympic(
            olympic_id=fake.unique.bothify(text="OLY####"),
            country_id=country.country_id,
            city=fake.city(),
            year=start_date.year,
            startdate=start_date,
            enddate=end_date
        )
        olympics.append(olympic)
        session.add(olympic)
    session.commit()
    return olympics


def populate_players(countries, num=20):
    players = []
    for _ in range(num):
        country = random.choice(countries)
        birth_date = fake.date_of_birth(minimum_age=18, maximum_age=40)

        player = Player(
            player_id=fake.unique.bothify(text="PL#######"),
            name=fake.name(),
            country_id=country.country_id,
            birthdate=birth_date
        )
        players.append(player)
        session.add(player)
    session.commit()
    return players


def populate_events(olympics, num=15):
    events = []
    for _ in range(num):
        olympic = random.choice(olympics)

        event = Event(
            event_id=fake.unique.bothify(text="EV####"),
            name=fake.word().capitalize() + " " + fake.word().capitalize(),
            eventtype=random.choice(["individual", "team"]),
            olympic_id=olympic.olympic_id,
            is_team_event=random.randint(0, 1),
            num_players_in_team=random.choice([1, 2, 4, 5]) if random.randint(0, 1) else None,
            result_noted_in=random.choice(["time", "distance", "points"])
        )
        events.append(event)
        session.add(event)
    session.commit()
    return events


def populate_results(events, players, num=30):
    medals = ["Gold", "Silver", "Bronze", None]
    for _ in range(num):
        event = random.choice(events)
        player = random.choice(players)

        result = Result(
            event_id=event.event_id,
            player_id=player.player_id,
            medal=random.choice(medals),
            result=round(random.uniform(5.0, 100.0), 2)
        )
        session.add(result)
    session.commit()


def main():
    Base.metadata.create_all(engine)

    # Заполнение данных
    countries = populate_countries(10)
    olympics = populate_olympics(countries, 5)
    players = populate_players(countries, 20)
    events = populate_events(olympics, 15)
    populate_results(events, players, 30)


if __name__ == "__main__":
    main()
