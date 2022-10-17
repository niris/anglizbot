psql:   ; docker exec -ti $(shell docker ps -f name=postgres --format {{.Names}}) psql ; docker ps -f name=postgres --format {{.Names}} | xargs -I@ docker exec -i @ psql -c "NOTIFY pgrst, 'reload schema';"
db_drop:; docker-compose down ; sudo rm -rf ./pgdata/ ; docker-compose up -d ; sleep 3
db_init:; docker ps -f name=postgres --format {{.Names}} | xargs -I@ docker exec -i @ psql -f sql/schema.sql
apk:    ; bubblewrap init --manifest http://0.0.0.0/static/manifest.json ; bubblewrap build
index:
	cp static/app.html index.html
	(cd static  ;ls | jq -Rs 'split("\n")[:-1]|map({name:.})') > static/index.html
	(cd media/md;ls *.md | jq -Rs 'split("\n")[:-1]|map({name:.})') > media/md/index.html
