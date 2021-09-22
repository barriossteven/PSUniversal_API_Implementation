# PSUniversal_API_Implementation

## .SYNOPSIS

This is an API system created using Powershell Universal to expose global virtual machine inventory information from across multple data sources. API is leveraged for reporting on a weekly basis, a graphical dashboard accesible via Web Browser, and raw API useful for other developers.

## .DESCRIPTION

A reporting system to obtain and aggregate global virtual machine data had previously been implemented. That sytem would aggregate all data using Powershell and email the results via a relay. This was useful for a while until other use cases arose where other scripts would benefit from using the raw information in Powershell. 

In an effort to solve this issue, Powershell Universal API framework is leveraged to obtain the global inventory data. Because the API system can run under a specified service account, there is no need to expose security access to user's requiring the inventory data. This cuts down on the number of people with privileged access to the system minimizing risk. 

Once the API system was created, the API could now be leveraged for 3 use cases:
  1. Windows10 Scheduled task can make calls to this API, gather the data, and email the report to specified parties akin to the original reporting system.
  2. Using Powershell Universal, a graphical user interface referred to as a dashboard can be constructed and allow for all of the data to be made accessible via Web Browser. Here, non-technical users can view and manipulate the data to create custom views and export the data if required. This also benefits admin by allowing quick access and comparative features incase of an outage or for troubleshooting purposes.
  3. The API calls can now be easily injected into other scripts minimizing the amount of code redundancy. Scripts that require this information need 2 lines of code to obtain the global inventory info.

## .ACCOMPLISHMENTS/WHAT I LEARNED

In addition to benefitting via the 3 bullets mentioned earlier, this implementation drastically improved my daily efficiency as well. Any information I required was easily accessible via a browser bookmark. If a custom report was required, I could either manipulate the data within the dashboard and export as a CSV or export the data and create more advanced filters in excel within seconds.

I was able to more efficiently design the reporting system by leveraging caching to quickly pull down the information if I did not require the most up-to-date entries. Overall, the API system reduced the runtime of the reporting engine by a few minutes. The API call can have all of the data collected within seconds.

Powershell Universal is a gargantuan platform that can be finely tailored to your needs. A lot of time was spent reading and learning about the Universal framework and many different features were attempted before settling for a final design. Server-side processing, dynamic elements, and request headers were just a few items that needed to be vetted out in an effort to make an elegant but efficient design.

## .AREAS OF IMPROVEMENT

The user interface is practical but lacks in aesthetic. Additionally, expanding on the dashboard features would be an area of interest.

## .NOTES

Dashboard source code is located in /Repository/Citrix Lab Environment.ps1.
API source code is located in /Repository/.universal/endpoints.ps1.

Script was created using Powershell 5.1 but is compatible with Powershell Core. Powershell Universal 2.2.0 was used for framework.
Requirements:
  1. ActiveDirectory
  2. PowerCLI
  3. Citrix Provisioning Services SDK
  4. Citrix Broker SDK
  5. Powershell Universal






