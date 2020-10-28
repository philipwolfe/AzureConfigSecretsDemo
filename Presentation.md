# Migrating to Azure App Configuration and Azure Key Vault
Philip Wolfe, Enterprise Architect, Orion Advisor Technology
Omaha .NET User Group, 10/29/2020

> Managing application settings and secrets can be challenging when you consider secure storage, environmental differences, and controlling access to these values.  In this rapid fire presentation, we will create an Azure App Config and Azure Key Vault to address with these concerns.  We will modify an on-prem app to switch from using values stored in the config file to calling the Azure resources through the Azure Microsoft Configuration Builders github project.  We will wrap up with a quick synopsis of pros/cons and lessons learned through Orion’s migration to storing values in the cloud.

# Main Concepts
### Azure Key Vault
Azure Key Vault is a cloud service for securely storing and accessing secrets. [Learn More](https://docs.microsoft.com/en-us/azure/key-vault/general/basic-concepts)
### Azure App Configuration
Azure App Configuration provides a service to centrally manage application settings and feature flags.  [Learn More](https://docs.microsoft.com/en-us/azure/azure-app-configuration/overview)
### Configuration Builders
Configuration builders provide a modern and agile mechanism for ASP.NET apps to get configuration values from external sources.  [Learn More](https://docs.microsoft.com/en-us/aspnet/config-builder) and [here](https://github.com/aspnet/MicrosoftConfigurationBuilders)

# Project Overview
These projects have settings and secrets in a config file:
- Console App
- Web Site


# Cloud Setup
1. Azure Resources
	```batch
	az login
	az group create --name "UG-Demo" -l "centralus"
	az keyvault create --name "UG-Keys-1" --resource-group "UG-Demo" --location "centralus"
	az appconfig create --name "UG-Config-1" --location "centralus" --resource-group "UG-Demo" --sku standard
	az ad sp create-for-rbac --name "UG-Demo-SPN" --skip-assignment --sdk-auth true
	az keyvault set-policy -n UG-Keys-1 --spn  --secret-permissions get list

	az group delete --name "UG-Demo"
	az ad sp delete --id 
	```

2. Create a secret key
3. Create a setting for the secret key
4. Create a setting

# Referencing Config Builders
From NuGet:
```powershell
Install-Package Azure.Core -Version 1.0.2
Install-Package Azure.Data.AppConfiguration -Version 1.0.0
Install-Package Azure.Identity -Version 1.1.1
Install-Package Azure.Security.KeyVault.Secrets -Version 4.1.0
Install-Package Microsoft.Configuration.ConfigurationBuilders.AzureAppConfiguration -Version 1.0.0
Install-Package Newtonsoft.Json -Version 12.0.1
```

# Configuring the sections
Config file sections:
```xml
<section name="configBuilders" type="System.Configuration.ConfigurationBuildersSection, System.Configuration, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"/>
```
```xml
<configBuilders>
	<builders>
		<add name="AzureSettings" prefix="" mode="Expand" stripPrefix="true" escapeExpandedValues="true" endpoint="https://APP_CONFIG_NAME.azconfig.io" useAzureKeyVault="true" type="Microsoft.Configuration.ConfigurationBuilders.AzureAppConfigurationBuilder, Microsoft.Configuration.ConfigurationBuilders.AzureAppConfiguration" />
	</builders>
</configBuilders>
```

# Replacing the settings
In each section, reference the config builder and substitute the setting name.
```xml
 <applicationSettings>
   <SECTION_NAME configBuilders="AzureSettings">
     <setting name="MySettingValue" serializeAs="String">
	<value>${AZURE_SETTING_KEY}</value>
     </setting>
   </SECTION_NAME>
</applicationSettings>
```


# Authentication
One last note about authentication.
The ConfigurationBuilders use the [DefaultAzureCredential](https://docs.microsoft.com/en-us/dotnet/api/azure.identity.defaultazurecredential?view=azure-dotnet) class.  This class is configured to try 
authentication in the following order:
- Environment Variables
- ManagedIdentiy (when running in Azure)
- SharedTokenCache (for Azure user tokens)
- Viaual Studio (users logged into Visual Studio)
- Visual Studio Code (users logged into Visual Studio Code)
- AzureCli (reuse a token from the cli)
- InteractiveBrowser (show a browser if supported)

Set these variables in codeor use a different authentication mechanism.
```csharp
Environment.SetEnvironmentVariable("Azure_Tenant_Id", "");
Environment.SetEnvironmentVariable("AZURE_CLIENT_ID", "");
Environment.SetEnvironmentVariable("AZURE_CLIENT_SECRET", "");
```


You can modify the source code so that it also uses the [AzureServiceTokenProvider](https://github.com/Azure/azure-sdk-for-net/blob/master/sdk/mgmtcommon/AppAuthentication/Azure.Services.AppAuthentication/AzureServiceTokenProvider.cs) 
which adds in the [WindowsAuthenticationAzureServiceTokenProvider](https://github.com/Azure/azure-sdk-for-net/blob/1b8ff2f57de9dbba493fa27a84e785489db74ed1/sdk/mgmtcommon/AppAuthentication/Azure.Services.AppAuthentication/TokenProviders/WindowsAuthenticationAccessTokenProvider.cs) 
which authenticates user accounts on a domain.