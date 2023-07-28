## PSci core api

### Setup

1. rvm install 2.7.7
1. postgres running on localhost
1. clone the repo
1. cd into the repo
1. confirm `psci` gemset exists and is active (`rvm gemset list`)
1. bundle install
1. setup db
    1. `rails db:create`
    1. `rails db:migrate`
1. Get .env seeds from JK
    1. `rails db:seed:development` (seedbank gem)

#### CD pipeline

- Merge to dev deploys to stag
- Merge to master deploys to prod

### Common CLI commands

- `rails s`
- `rails c`
- `rails db:migrate:status`
- `rails routes`

### Working on the project

- pull at the start of each work session
- branch off of the current dev branch
- push at the end of each work session
  - mark WIP feature branches `-wip`
- never merge into dev (unless asked)
- create PR and ask JK for review / comment / merge

### Trello assignments

- pull assigned cards from the top of "Next"
- move card to "Underway" begining of the day
- put back into "Next" end of the day
- put into "Done" when PR is created
