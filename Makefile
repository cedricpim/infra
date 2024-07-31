ENV ?= development
NAMESPACE ?= app

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
	docker build -t infra:latest --build-arg BUNDLE_WITHOUT= --build-arg RAILS_ENV=$(ENV) .

console:
	kubectl exec -it $$(kubectl get pods -o name -A | grep console) --namespace=$(NAMESPACE) -- bundle exec rails console

scale:
	test -n "$(SERVICE)" # $$SERVICE
	test -n "$(REPLICAS)" # $$REPLICAS
	kubectl scale deployment/$(SERVICE) --replicas=$(REPLICAS) --namespace=$(NAMESPACE)

logs:
	kubectl logs -f -l app=infra-app --prefix --namespace=$(NAMESPACE)

deploy:
	kubectl rollout restart deployment/app --namespace=$(NAMESPACE)
	kubectl rollout restart deployment/sidekiq --namespace=$(NAMESPACE)
	kubectl rollout restart deployment/console --namespace=$(NAMESPACE)

attach:
	test -n "$(SERVICE)" # $$SERVICE
	kubectl attach -it $$(kubectl get pods -o name -A | grep $(SERVICE)) --namespace=$(NAMESPACE)

clean:
	minikube delete --all --purge
