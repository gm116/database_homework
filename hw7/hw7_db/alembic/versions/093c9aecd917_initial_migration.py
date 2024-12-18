"""Initial migration

Revision ID: 093c9aecd917
Revises: 
Create Date: 2024-11-03 20:11:36.896168

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '093c9aecd917'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # ### commands auto generated by Alembic - please adjust! ###
    op.alter_column('countries', 'country_id',
               existing_type=sa.CHAR(length=3),
               type_=sa.String(length=3),
               nullable=False)
    op.alter_column('countries', 'name',
               existing_type=sa.CHAR(length=40),
               type_=sa.String(length=40),
               nullable=False)
    op.alter_column('events', 'event_id',
               existing_type=sa.CHAR(length=7),
               type_=sa.String(length=7),
               nullable=False)
    op.alter_column('events', 'name',
               existing_type=sa.CHAR(length=40),
               type_=sa.String(length=40),
               nullable=False)
    op.alter_column('events', 'eventtype',
               existing_type=sa.CHAR(length=20),
               type_=sa.String(length=20),
               existing_nullable=True)
    op.alter_column('events', 'olympic_id',
               existing_type=sa.CHAR(length=7),
               type_=sa.String(length=7),
               existing_nullable=True)
    op.alter_column('events', 'result_noted_in',
               existing_type=sa.CHAR(length=100),
               type_=sa.String(length=100),
               existing_nullable=True)
    op.alter_column('olympics', 'olympic_id',
               existing_type=sa.CHAR(length=7),
               type_=sa.String(length=7),
               nullable=False)
    op.alter_column('olympics', 'country_id',
               existing_type=sa.CHAR(length=3),
               type_=sa.String(length=3),
               existing_nullable=True)
    op.alter_column('olympics', 'city',
               existing_type=sa.CHAR(length=50),
               type_=sa.String(length=50),
               existing_nullable=True)
    op.alter_column('players', 'player_id',
               existing_type=sa.CHAR(length=10),
               type_=sa.String(length=10),
               nullable=False)
    op.alter_column('players', 'name',
               existing_type=sa.CHAR(length=40),
               type_=sa.String(length=40),
               nullable=False)
    op.alter_column('players', 'country_id',
               existing_type=sa.CHAR(length=3),
               type_=sa.String(length=3),
               existing_nullable=True)
    op.alter_column('results', 'event_id',
               existing_type=sa.CHAR(length=7),
               type_=sa.String(length=7),
               nullable=False)
    op.alter_column('results', 'player_id',
               existing_type=sa.CHAR(length=10),
               type_=sa.String(length=10),
               nullable=False)
    op.alter_column('results', 'medal',
               existing_type=sa.CHAR(length=7),
               type_=sa.String(length=7),
               existing_nullable=True)
    # ### end Alembic commands ###


def downgrade() -> None:
    # ### commands auto generated by Alembic - please adjust! ###
    op.alter_column('results', 'medal',
               existing_type=sa.String(length=7),
               type_=sa.CHAR(length=7),
               existing_nullable=True)
    op.alter_column('results', 'player_id',
               existing_type=sa.String(length=10),
               type_=sa.CHAR(length=10),
               nullable=True)
    op.alter_column('results', 'event_id',
               existing_type=sa.String(length=7),
               type_=sa.CHAR(length=7),
               nullable=True)
    op.alter_column('players', 'country_id',
               existing_type=sa.String(length=3),
               type_=sa.CHAR(length=3),
               existing_nullable=True)
    op.alter_column('players', 'name',
               existing_type=sa.String(length=40),
               type_=sa.CHAR(length=40),
               nullable=True)
    op.alter_column('players', 'player_id',
               existing_type=sa.String(length=10),
               type_=sa.CHAR(length=10),
               nullable=True)
    op.alter_column('olympics', 'city',
               existing_type=sa.String(length=50),
               type_=sa.CHAR(length=50),
               existing_nullable=True)
    op.alter_column('olympics', 'country_id',
               existing_type=sa.String(length=3),
               type_=sa.CHAR(length=3),
               existing_nullable=True)
    op.alter_column('olympics', 'olympic_id',
               existing_type=sa.String(length=7),
               type_=sa.CHAR(length=7),
               nullable=True)
    op.alter_column('events', 'result_noted_in',
               existing_type=sa.String(length=100),
               type_=sa.CHAR(length=100),
               existing_nullable=True)
    op.alter_column('events', 'olympic_id',
               existing_type=sa.String(length=7),
               type_=sa.CHAR(length=7),
               existing_nullable=True)
    op.alter_column('events', 'eventtype',
               existing_type=sa.String(length=20),
               type_=sa.CHAR(length=20),
               existing_nullable=True)
    op.alter_column('events', 'name',
               existing_type=sa.String(length=40),
               type_=sa.CHAR(length=40),
               nullable=True)
    op.alter_column('events', 'event_id',
               existing_type=sa.String(length=7),
               type_=sa.CHAR(length=7),
               nullable=True)
    op.alter_column('countries', 'name',
               existing_type=sa.String(length=40),
               type_=sa.CHAR(length=40),
               nullable=True)
    op.alter_column('countries', 'country_id',
               existing_type=sa.String(length=3),
               type_=sa.CHAR(length=3),
               nullable=True)
    # ### end Alembic commands ###
