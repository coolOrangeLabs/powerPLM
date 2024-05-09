# Item centric Items and BOM Workflow - Items Workspace

## Workflow:
https://doc.coolorange.com/projects/powerflc/en/stable/workflows/transfer_item_boms/

The entire workflow is based on PowerShell scripts and can be customized if needed.

## Prerequisites
The option **Enable Job Server** must be set in the **Job Server Management** in Vault and the installation explained below must be executed on a Job Processor machine.  
The coolOrange products "powerJobs Processor" and "powerFLC" must be installed on the Job Processor machine. Both products can be downloaded from http://download.coolorange.com. 

## Workflow Installation
- Copy the files located in Jobs and Modules to “C:\ProgramData\coolOrange\powerJobs”
- In Vault, open the “**powerFLC Configuration Manager**” from the tools menu
- Import the workflow “**Sample.TransferItemBOMs.json**” using the "Import" button
- Once imported, double-click the workflow to adjust the settings

## Settings
https://doc.coolorange.com/projects/powerflc/en/stable/workflows/transfer_item_boms/#configuration

## Product documentation
powerFLC: https://doc.coolorange.com/projects/coolorange-powerflcdocs/en/stable/  
powerJobs Processor: https://doc.coolorange.com/projects/coolorange-powerjobsprocessordocs/en/stable/  

## At your own risk
The usage of these samples is at your own risk. There is no free support related to the samples. However, if you have questions to powerJobs or powerFLC, then visit http://www.coolorange.com/wiki or start a conversation in our support forum at http://support.coolorange.com/support/discussions