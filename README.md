# Wallet Tracker

This service is a wallet tracker that allows you to track your expenses and incomes.
Keep check of any malicious activity in your wallet.

## Clone the repo

```BASH
git clone git@github.com:JoaoSetas/wallet-tracker.git
cp .hooks/* .git/hooks/
```

## Configuring .env
Create the folder `.env` from the `.env.example`

#### `SECRET_KEY_BASE` - Generate with:
```BASH
docker-compose run --rm phoenix bash -c "echo 'SECRET_KEY_BASE:' & mix phx.gen.secret"
```
## Running the app
Start the containers
```BASH
docker-compose up -d
```
Now you should see the app in http://localhost:4000/

Check postman docs for api calls
[text](https://documenter.getpostman.com/view/3256126/2s9YsRbokj)
# Development
Checks before commit
```BASH
docker-compose run --rm phoenix sh pre-commit-script
```
Get logs
```BASH
docker-compose logs -f
```
Connect to the container
```BASH
docker-compose exec phoenix bash
```
# Debug

Connect to the iex with 
```BASH
docker-compose exec phoenix iex --sname console --cookie monster --remsh cookie
```
To debug in the iex put this in your code to break 
```elixir
require IEx; IEx.pry
```
To debug to the console
```elixir
dbg(variable)
```
It needed in the iex this command recompiles any changes 
```elixir
recompile
```
