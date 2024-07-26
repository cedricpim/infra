ENV ?= development

setup:
	kubectl apply -f kube/env.yaml
	kubectl apply -f kube/secrets.yaml
	kubectl apply -f kube/postgres
	kubectl apply -f kube/redis
	kubectl apply -f kube/app
	kubectl apply -f kube/sidekiq
	kubectl apply -f kube/console

build:
	eval $(minikube -p minikube docker-env)
	minikube image build -t infra:latest .

console:
	kubectl exec -it $$(kubectl get pods -o name | grep console) -- bundle exec rails console

scale:
	test -n "$(SERVICE)" # $$SERVICE
	test -n "$(REPLICAS)" # $$REPLICAS
	kubectl scale deployment/$(SERVICE) --replicas=$(REPLICAS)

logs:
	kubectl logs -f -l app=infra-app --prefix

deploy:
	kubectl rollout restart deployment/app
	kubectl rollout restart deployment/sidekiq
	kubectl rollout restart deployment/console

attach:
	test -n "$(SERVICE)" # $$SERVICE
	kubectl attach -it $$(kubectl get pods -o name | grep $(SERVICE))

clean:
	minikube delete --all --purge
