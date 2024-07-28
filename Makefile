ENV ?= development

setup:
	kubectl apply -f kube/app/namespace.yaml
	kubectl kustomize kube/app/overlays/$(ENV)/ | kubectl apply -f -
	kubectl apply -f kube/app/postgres
	kubectl apply -f kube/app/redis
	kubectl apply -f kube/app/app
	kubectl apply -f kube/app/sidekiq
	kubectl apply -f kube/app/console

build:
	eval $$(minikube -p minikube docker-env)
	minikube image build -t infra:latest .

console:
	kubectl exec -it $$(kubectl get pods -o name -A | grep console) --namespace=app -- bundle exec rails console

scale:
	test -n "$(SERVICE)" # $$SERVICE
	test -n "$(REPLICAS)" # $$REPLICAS
	kubectl scale deployment/$(SERVICE) --replicas=$(REPLICAS) --namespace=app

logs:
	kubectl logs -f -l app=infra-app --prefix --namespace=app

deploy:
	kubectl rollout restart deployment/app --namespace=app
	kubectl rollout restart deployment/sidekiq --namespace=app
	kubectl rollout restart deployment/console --namespace=app

attach:
	test -n "$(SERVICE)" # $$SERVICE
	kubectl attach -it $$(kubectl get pods -o name -A | grep $(SERVICE)) --namespace=app

clean:
	minikube delete --all --purge
