# TopJobs and ITPro HTML Fixtures for Deterministic Offline Testing

SAMPLE_TOPJOBS_HTML = """
<!DOCTYPE html>
<html>
<head><title>TopJobs Sri Lanka - Vacancies</title></head>
<body>
<table id="table1">
    <tr id="tr0">
        <td class="center">1</td>
        <td>
            <input type="hidden" id="hdnJC0" value="0001541300">
            <input type="hidden" id="hdnEC0" value="0000000300">
            <input type="hidden" id="hdnAC0" value="0000000030">
            <a href="javascript:createAlert('0','0000000030','0001541300','0000000300','0');">
                <h2>Senior Software Engineer (Java / Microservices)</h2>
            </a>
            <h1>Sysco LABS Sri Lanka</h1>
        </td>
        <td>Colombo</td>
        <td>Fri Aug 28 2026</td>
    </tr>
    <tr id="tr1">
        <td class="center">2</td>
        <td>
            <input type="hidden" id="hdnJC1" value="0001541301">
            <input type="hidden" id="hdnEC1" value="0000000301">
            <input type="hidden" id="hdnAC1" value="0000000030">
            <a href="javascript:createAlert('1','0000000030','0001541301','0000000301','1');">
                <h2>QA Automation Engineer (Selenium / Python)</h2>
            </a>
            <h1>99x</h1>
        </td>
        <td>Colombo</td>
        <td>Thu Aug 27 2026</td>
    </tr>
    <tr id="tr2">
        <td class="center">3</td>
        <td>
            <input type="hidden" id="hdnJC2" value="0001541302">
            <input type="hidden" id="hdnEC2" value="0000000302">
            <input type="hidden" id="hdnAC2" value="0000000030">
            <a href="javascript:createAlert('2','0000000030','0001541302','0000000302','2');">
                <h2>DevOps & Cloud Specialist (AWS / Terraform)</h2>
            </a>
            <h1>IFS Sri Lanka</h1>
        </td>
        <td>Colombo</td>
        <td>Wed Aug 26 2026</td>
    </tr>
</table>
</body>
</html>
"""

SAMPLE_ITPRO_LIST_HTML = """
<!DOCTYPE html>
<html>
<head><title>IT Jobs in Sri Lanka | ITPro.lk</title></head>
<body>
<div class="job-listings">
    <div class="job-item">
        <a href="https://itpro.lk/job/14876/associate-frontend-engineer-at-kangaro-tech/">Associate Frontend Engineer</a>
    </div>
    <div class="job-item">
        <a href="https://itpro.lk/job/14875/associate-uiux-engineer-at-kangaro-tech/">Associate UI/UX Engineer</a>
    </div>
    <div class="job-item">
        <a href="https://itpro.lk/job/14201/data-engineer-at-healthrecon-connect-llc/">Data Engineer</a>
    </div>
</div>
</body>
</html>
"""

SAMPLE_ITPRO_JOB_HTML = """
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Associate Frontend Engineer at Kangaro Tech - Colombo, Sri Lanka | ITPro.lk</title>
    <meta name="description" content="Join Kangaro Tech as a Associate Frontend Engineer in Colombo, Full-time. Requirements: 1-2 years experience with React, TypeScript, and Tailwind CSS. Salary LKR 120,000 - 180,000." />
</head>
<body>
    <div class="job-header">
        <h1>Associate Frontend Engineer</h1>
        <div class="company-name">Kangaro Tech</div>
        <div class="location">Colombo, Sri Lanka</div>
    </div>
    <div class="job-description">
        <p>We are looking for an Associate Frontend Engineer with 1-2 years experience in React, TypeScript, HTML5, and CSS3. Familiarity with Git, REST APIs, and Docker is an added advantage. Work mode is Hybrid.</p>
    </div>
</body>
</html>
"""
