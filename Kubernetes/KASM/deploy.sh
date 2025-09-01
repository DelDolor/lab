# kloonaa chart
git clone https://github.com/kasmtech/kasm-helm
cd kasm-helm
# valitse julkaisuhaara, esim:
git checkout release/1.17.0

# asenna
helm upgrade --install kasm ./kasm-single-zone \
  --namespace kasm --create-namespace \
  -f ./values.yaml

kubectl -n kasm wait --for=condition=Available deploy --all --timeout=5m
kubectl -n kasm get svc

# testaa portforwardilla
kubectl -n kasm port-forward svc/kasm-proxy 8443:443
# avaa selaimella: https://localhost:8443
