# 1.0 Azure Automation Plus DSC lab

This template deploys a new lab environment that can be used for training, practice and demonstrations for the following topics:

1. Azure Automation
2. Azure Automation Desired State Configuration
3. Windows PowerShell
4. Windows PowerShell Desired State Configuration
5. PowerShell Core 6.0
6. Powershell DSC for Linux

## Target State Diagram

![Target state diagram](https://github.com/autocloudarc/0026-azure-automation-plus-dsc-lab/blob/master/images/0026-infrastructure-diagram.png)

## 2.0 Prerequisites

Decscription of the prerequistes for the deployment

1. An Azure subscription
2. A web browser
3. An Internet connection
4. Windows PowerShell Version 5.1
5. Membership in the local Administrators group on the machine on which you will execute the PowerShell script.
6. The password required must be at least 12 characters and meet complexity requirements, i.e. 3 out of 4 of upper case, lower case, numeric and special characters.

## 3.0 Lab Infrastructure

The lab infrastructure includes the following components:

1. 1 x resource group named rg##, where ## in this document represents a one or two-digit number between 0 to 16, and reflects the student number you specify during deployment.

2. 3 x Windows 2016 Data Center Core domain controllers, where only 1 has been promoted to a domain controller: AZRADS##03.dev.adatum.com. AZRADS##01 & AZRADS##02 are only member servers until you promoting them.

3. 2 x Windows 2016 Data Center with GUI domain controllers, that have not actually been promoted to DCs as yet, since this will provide you with the opportunity to practice promoting them using either PowerShell remoting or Desired State Configuration. These VM names are AZRADG##01.dev.adatum.com and AZRADG##02.dev.adatum.com.

3. 1 x Widnows 2016 Data Center Development/Jump/DSCPull/DSCPush server w/the Visual Studio 2017 Community Edition VM image. This will be AZRDEV##01.dev.adatum.com.

4. 2 x Windows 2016 Data Center Core servers, initially deployed as standalone servers but which can be configured after deployment as web servers using DSC. These are AZRWEB##01 and AZRWEB##02.

5. 2 x Widnows 2016 Data Center servers, initially deployed as standalone servers but which can be configured after deployment as SQL 2016 servers using DSC. These are AZRSQL##01 and AZRSQL##02.

6. 1 x CentOS 7 server, which can be used to demonstrate or practice PowerShell Core 6.0 or PowerShell DSC for Linux concepts. This is AZRLNX##01.

7. 1 x Windows 2016 Data Center with GUI PKI server. This is really just a base Windows VM image that you can also practice configuring as a PKI server.

8. 1 x Automation account for Azure automation topics. This resource is named aaa-{studentRandomInfix}-##.

9. 1 x OMS Workspace for Runbook monitoring integration, named oms-{studentRandomInfix}-##.

10. 1 x storage account used for boot diagnostics and diagnostics logging for each VM. The name will be globally unique in DNS if you deploy from the Powershell script

11. 1 x recovery services vault for VM backup and recovery.

## 4.0 Deploying The Template

Windows PowerShell

1. Clone or download the Deploy-AzureResourceGroup.ps1 to a directory where you want to execute the script from.

2. Open your favorite Windows PowerShell host as an administrative user. You can use Visual Studio Code, Visual Studio, PowerShell ISE, PowerShell console, or other 3rd party host.

3. Right-click and unblock the script so that your PowerShell execution policy if set to RemoteSigned will allow it to run.

4. Open and execute the script. The example below assumes you are already in the current script directory.

    .\Deploy-AzureResourceGroup.ps1

4. When the script executes, answer the following prompts:

    - Authenticate to your subscription
    - Enter your target subscription name
    - Enter your student number, which is a number from 0 to 16.
    - Enter your administrator password for the adm.infra.user account. Your password will not be exposed.

Azure CLI (bash)

4.6 If you prefer to use the Azure CLI to deploy this solution, use the code block below:

    # Authenticate to azure
    az login

    # Create a password for the adm.infra.user account for each VM to be deployed. CATION: This password will be shown in clear text.
    adminPassword={'specify your own password here'}

    # Create a random student infix that will be used to name the storage account, automation account, OMS workspace and recovery services vault.
    studentRandomInfix=$(uuidgen | cut -c1-8)

    # Assign the adm.infra.user account for each VM to be deployed.
    adminUserName=adm.infra.user

    # Assign a student number from [0-16] to disambiguate deployed resources from other attendees for multiple participants in a class/training scenario.
    studentNumber=##

    # Assign a resource group for all resources, where ## is the same as your student number above.
    rg=rg##

    # Specify the azure region closest to your location, i.e. eastus2 for East US 2 or westus2 for West US 2.
    location={location}

    # Assign the following uri value exactly as shown.
    uri="https://raw.githubusercontent.com/autocloudarc/0026-azure-automation-plus-dsc-lab/master/azuredeploy.json"

    # Assign a deployment name.
    rgDeployment=rg##deployment

    # Create a resource group
    az group create --name $rg --location $location

    # Be carefull when pasting multiple lines due to the differences in CRLF support for certain text editors/IDEs.
    az group deployment create \
    --name $rgDeployment \
    --resource-group $rg \
    --template-uri $uri \
    --parameters adminUserName=$adminUserName adminPassword=$adminPassword studentRandomInfix=$studentRandomInfix studentNumber=$studentNumber

## 5.0 Connecting to your Lab

1. If you use the PowerShell script method to deploy this lab, your RDP prompt will open automatically to the development/jump server AZRDEV##01 VM.

2. If you use the Azure CLI (bash) method, then you will need to use your browser to authenticate to your subscription from <https://portal.azure.com> and click connect icon from the AZRDEV##01 VM overview blade in the portal.

The username to use is: adm.infra.user@dev.adatum.com

## 6.0 After Deploying the Template (Usage)

Although particular scenarios or specific sets of excercises are not provided as part of this project to practice these skills, listed here is the recommended outline of training objectives as a basic guide.
You may deviate, ommit, add or re-sequence these steps as necessary to meet your test/dev/training requirements.
Please NOTE that this project is primarily for training and NOT recommended for production.

For a hands-on excercises or training/class scenarios, where all attendees will be deploying their own lab, a single subscription can be used, but you may have to request increases in core or other resource limits by
submitting an Azure support ticket through this subscription. You may also consider assigning a seperate subscription to each attendee so that resource limits will not be exceeded.
Special care was taken to ensure that multiple attendees can perform simultaneous deployments without resource name conflicts within the same subscription. This is due to the student numbers assigned to each attendee, and supports numbers from 0-16. For example, the ## symbols below represents the student number of the VMs, ranging from 0-16.

SUGGESTED LAB EXERCISES

1. Build the AZRDEV##01 server as a jump/dev DSC pull server using desired state configuration in local push configuration mode.

2. Build the AZRWEB##01 web server as a web server using push mode remotely from AZRDEV##01.

3. Build the AZRADS##01 domain controller as a domain controller using push mode remotely from AZRDEV##01.

4. Build the AZRADG##01 domain controller as a DC. The "G" in ADG means it has a GUI interface.

5. Build the AZRSQL##01 SQL 2016 server as an SQL server using push mode remotely from AZRDEV##01.

6. Apply a configuration to AZRWEB##01 using the DSC Pull server AZRDEV##01.

7. Apply a configuration to AZRADS##01 using the DSC Pull server AZRDEV##01.

8. Apply a configuration to AZRSQL##01 using the DSC Pull server AZRDEV##01.

9. Build the AZRWEB##02 web server as a web server using Azure Automation DSC (AA DSC).

10. Build the AZRADS##02 domain controller as a domain controller using AA DSC.

11. Build the AZRSQL##02 SQL 2016 server as an SQL server using AA DSC.

11. Apply a configuration to the AZRLNX##01 Linux CentOS server using the push mode remotely from AZRDEV##01.

13. Apply a configuration to the AZRLNX##01 Linux CentOS server using AA DSC.

## 8.0 Target State Diagram

![Target State Diagram](https://github.com/autocloudarc/0026-azure-automation-plus-dsc-lab/blob/master/images/0026-azure-automation-plus-dsc-lab.png)

## 9.0 Notes

1. *This solution does not include a hybrid connection to an on-premises environment.*
2. *All Windows VMs are domain joined during the deployment.*

## 6.0 References

Here are some references for Azure Automation, PowerShell and Desired State Configuration that can be used during your learning and exploration of these topics.

LINKS

1. Azure Automation: <https://docs.microsoft.com/en-us/azure/>
2. Desired State Configuration: <https://docs.microsoft.com/en-us/powershell/dsc/overview>
3. Desired State Configuration for Linux: <https://docs.microsoft.com/en-us/powershell/dsc/lnxgettingstarted>
4. Powershell Core: <https://docs.microsoft.com/en-us/powershell/scripting/whats-new/what-s-new-in-powershell-core-60?view=powershell-6>
5. Example Scenario: <https://blogs.technet.microsoft.com/askpfeplat/2017/10/16/windows-powershell-and-dsc-on-linux-in-microsoft-azure/>
6. Example Scenario: https://blogs.msdn.microsoft.com/powersql/2017/12/13/install-sql-server-2017-using-powershell-desired-state-configuration-and-sqlserverdsc/

BOOKS

1. Windows PowerShell in Action, 3rd Edition – Bruce Payette & Richard Siddaway (See Chapter 18. Desired State Configuration)
2. Windows PowerShell Desired State Configuration Revealed – Ravikanth Chaganti
3. Learning PowerShell DSC – James Pogran
4. PowerShell 5.1 and Desired State Configuration – Ron Davis

## 10.0 Tags

`Tags: Azure Automation Lab, Azure, Automation, Windows Powershell, Desired State Configuration, DSC, PowerShell Core, Linux`
