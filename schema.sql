CREATE TABLE raw_pathway (
    name varchar (150) PRIMARY KEY,
    description varchar (200));
  
CREATE TABLE raw_module (
    name varchar (150) PRIMARY KEY,
    description varchar (200));
  
CREATE TABLE raw_pathway_module (
    pathway varchar (150),
    module varchar (150));
  
  
CREATE TABLE pathway (
  id serial PRIMARY KEY,
    name varchar (150),
    description varchar (200));
  
CREATE TABLE module (
  id serial PRIMARY KEY,
    name varchar (150),
    description varchar (200));
  
CREATE TABLE pathway_module (
  id serial PRIMARY KEY,
    pathway NUMERIC,
    module NUMERIC );
