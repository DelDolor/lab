# https://homarr.dev

#install using helm
helm repo add homarr-labs https://homarr-labs.github.io/charts/
helm repo update

#generate secrets
DB_ENC_KEY=$(openssl rand -hex 32)

kubectl create secret generic db-secret \
  --from-literal=password='qwerty' \
  --from-literal=db-encryption-key="$DB_ENC_KEY" \
  -n homarr

helm install homarr homarr-labs/homarr --namespace homarr --create-namespace --values=homarr-helm/values.yaml

#uninstall
helm uninstall homarr