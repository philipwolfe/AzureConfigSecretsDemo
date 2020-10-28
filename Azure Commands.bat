az login

az group create --name "UG-Demo" -l "centralus"

az keyvault create --name "UG-Keys-1" --resource-group "UG-Demo" --location "centralus"

az appconfig create --name "UG-Config-1" --location "centralus" --resource-group "UG-Demo" --sku standard

az ad sp create-for-rbac --name "UG-Demo-SPN" --skip-assignment --sdk-auth true

az keyvault set-policy -n UG-Keys-1 --spn  --secret-permissions get list

az group delete --name "UG-Demo"
az ad sp delete --id 

