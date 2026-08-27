// ==============================================================================
// TechScape: Analytical Dashboard Logic (dashboard/app.js)
// ==============================================================================

document.addEventListener('DOMContentLoaded', () => {
  const data = window.TECHSCAPE_DATA || { jobs: [], skills: [], macro: [] };
  
  // State
  let activeTab = 'overview';
  let filterState = {
    career: 'ALL',
    seniority: 'ALL',
    workMode: 'ALL'
  };

  // Elements
  const navItems = document.querySelectorAll('.nav-item');
  const tabPanels = document.querySelectorAll('.tab-panel');
  const pageTitle = document.getElementById('page-title');
  const pageSubtitle = document.getElementById('page-subtitle');
  
  const filterCareer = document.getElementById('filter-career');
  const filterSeniority = document.getElementById('filter-seniority');
  const filterMode = document.getElementById('filter-mode');
  const btnReset = document.getElementById('btn-reset-filters');

  // Populate Career Filter Options
  const uniqueCareers = Array.from(new Set(data.jobs.map(j => j.career_category))).filter(Boolean).sort();
  uniqueCareers.forEach(c => {
    const opt = document.createElement('option');
    opt.value = c;
    opt.textContent = c;
    filterCareer.appendChild(opt);
  });

  // Tab Navigation Handling
  const tabMetadata = {
    overview: { title: "Executive Labour Market Overview", subtitle: "Empirical insights from verified Sri Lankan IT job postings and national employment indicators" },
    careers: { title: "Career Category Dynamics (RQ2)", subtitle: "Market share and specialization demand across standardized career tracks" },
    skills: { title: "Technical Skills Demand (RQ3)", subtitle: "Penetration rates across programming languages, cloud platforms, and tooling" },
    salary: { title: "Compensation & Currency Dynamics (RQ6)", subtitle: "Observed LKR distributions, USD-pegged structures, and seniority benchmarks" },
    experience: { title: "Experience Requirements & Accessibility (RQ4, RQ5)", subtitle: "Minimum experience spread and entry-level accessibility ratios" },
    macro: { title: "Macroeconomic Context (RQ7)", subtitle: "DCS National/Youth Unemployment and CBSL ICT Service Export Earnings" },
    advisory: { title: "Student Insights & Career Guidance", subtitle: "Actionable, evidence-backed advice for Sri Lankan IT undergraduates" },
    explorer: { title: "Empirical Postings & Audit Registry", subtitle: "100% traceable record explorer with verified source URLs and raw fields" }
  };

  navItems.forEach(btn => {
    btn.addEventListener('click', () => {
      const target = btn.getAttribute('data-tab');
      if (target === activeTab) return;

      navItems.forEach(b => b.classList.remove('active'));
      tabPanels.forEach(p => p.classList.remove('active'));

      btn.classList.add('active');
      const panel = document.getElementById(`tab-panel-${target}`) || document.getElementById(`tab-${target}`);
      if (panel) panel.classList.add('active');

      activeTab = target;
      if (tabMetadata[target]) {
        pageTitle.textContent = tabMetadata[target].title;
        pageSubtitle.textContent = tabMetadata[target].subtitle;
      }
      renderCurrentTab();
    });
  });

  // Filter Listeners
  filterCareer.addEventListener('change', (e) => { filterState.career = e.target.value; updateDashboard(); });
  filterSeniority.addEventListener('change', (e) => { filterState.seniority = e.target.value; updateDashboard(); });
  filterMode.addEventListener('change', (e) => { filterState.workMode = e.target.value; updateDashboard(); });
  
  btnReset.addEventListener('click', () => {
    filterState = { career: 'ALL', seniority: 'ALL', workMode: 'ALL' };
    filterCareer.value = 'ALL';
    filterSeniority.value = 'ALL';
    filterMode.value = 'ALL';
    updateDashboard();
  });

  function getFilteredJobs() {
    return data.jobs.filter(job => {
      if (filterState.career !== 'ALL' && job.career_category !== filterState.career) return false;
      if (filterState.seniority !== 'ALL' && job.seniority_level !== filterState.seniority) return false;
      if (filterState.workMode !== 'ALL' && job.work_mode !== filterState.workMode) return false;
      return true;
    });
  }

  function updateDashboard() {
    const filteredJobs = getFilteredJobs();
    const filteredJobIds = new Set(filteredJobs.map(j => j.job_id));
    const filteredSkills = data.skills.filter(s => filteredJobIds.has(s.job_id));

    // Update KPI Ribbon
    const totalCount = filteredJobs.length;
    document.getElementById('kpi-total-jobs').textContent = totalCount;

    const entryCount = filteredJobs.filter(j => j.is_entry_level).length;
    const entryPct = totalCount > 0 ? ((entryCount / totalCount) * 100).toFixed(1) : '0.0';
    document.getElementById('kpi-entry-pct').textContent = `${entryPct}%`;

    const lkrJobs = filteredJobs.filter(j => j.currency === 'LKR' && j.salary_midpoint !== null);
    if (lkrJobs.length > 0) {
      const sortedMids = lkrJobs.map(j => j.salary_midpoint).sort((a, b) => a - b);
      const medianLKR = sortedMids[Math.floor(sortedMids.length / 2)];
      document.getElementById('kpi-median-salary').textContent = `LKR ${Math.round(medianLKR / 1000)}k`;
    } else {
      document.getElementById('kpi-median-salary').textContent = 'N/A';
    }

    const usdCount = filteredJobs.filter(j => j.currency === 'USD').length;
    const usdPct = totalCount > 0 ? ((usdCount / totalCount) * 100).toFixed(1) : '0.0';
    document.getElementById('kpi-usd-ratio').textContent = `${usdPct}%`;

    renderCurrentTab();
  }

  function renderCurrentTab() {
    const jobs = getFilteredJobs();
    const jobIds = new Set(jobs.map(j => j.job_id));
    const skills = data.skills.filter(s => jobIds.has(s.job_id));

    if (activeTab === 'overview') {
      renderOverviewCharts(jobs, skills);
    } else if (activeTab === 'careers') {
      renderCareersTable(jobs);
    } else if (activeTab === 'skills') {
      renderSkillsCharts(jobs, skills);
    } else if (activeTab === 'salary') {
      renderSalaryCharts(jobs);
    } else if (activeTab === 'experience') {
      renderExperienceCharts(jobs);
    } else if (activeTab === 'macro') {
      renderMacroCharts();
    } else if (activeTab === 'explorer') {
      renderExplorerTable(jobs);
    }
  }

  // --- Render Helpers ---

  function renderOverviewCharts(jobs, skills) {
    // 1. Career Distribution
    const careerCounts = {};
    jobs.forEach(j => { careerCounts[j.career_category] = (careerCounts[j.career_category] || 0) + 1; });
    const careerArr = Object.entries(careerCounts).sort((a, b) => b[1] - a[1]);
    renderHorizontalBarChart('chart-career-dist', careerArr, jobs.length, '#10b981');

    // 2. Top Skills
    const skillCounts = {};
    skills.forEach(s => { skillCounts[s.skill_name] = (skillCounts[s.skill_name] || 0) + 1; });
    const topSkillsArr = Object.entries(skillCounts).sort((a, b) => b[1] - a[1]).slice(0, 10);
    renderHorizontalBarChart('chart-top-skills', topSkillsArr, jobs.length, '#6366f1');

    // 3. Work Mode
    const modeCounts = {};
    jobs.forEach(j => { modeCounts[j.work_mode] = (modeCounts[j.work_mode] || 0) + 1; });
    const modeArr = Object.entries(modeCounts).sort((a, b) => b[1] - a[1]);
    renderHorizontalBarChart('chart-work-mode', modeArr, jobs.length, '#0ea5e9');

    // 4. Macro Quick View
    renderMacroSummaryChart('chart-macro-summary');
  }

  function renderHorizontalBarChart(containerId, dataArr, total, barColor) {
    const container = document.getElementById(containerId);
    if (!container) return;
    container.innerHTML = '';

    if (dataArr.length === 0) {
      container.innerHTML = '<div style="color:var(--text-dim);padding:20px;">No records match the active filter criteria.</div>';
      return;
    }

    const maxVal = dataArr[0][1];
    dataArr.forEach(([label, count]) => {
      const pct = ((count / Math.max(1, total)) * 100).toFixed(1);
      const widthPct = ((count / Math.max(1, maxVal)) * 100).toFixed(0);

      const row = document.createElement('div');
      row.className = 'bar-row';
      row.innerHTML = `
        <div class="bar-label" title="${label}">${label}</div>
        <div class="bar-track">
          <div class="bar-fill" style="width: ${widthPct}%; background: ${barColor || '#6366f1'};"></div>
        </div>
        <div class="bar-value">${count} (${pct}%)</div>
      `;
      container.appendChild(row);
    });
  }

  function renderCareersTable(jobs) {
    const tbody = document.querySelector('#table-career-summary tbody');
    if (!tbody) return;
    tbody.innerHTML = '';

    const grouped = {};
    jobs.forEach(j => {
      if (!grouped[j.career_category]) {
        grouped[j.career_category] = { count: 0, entry: 0, salaries: [] };
      }
      grouped[j.career_category].count++;
      if (j.is_entry_level) grouped[j.career_category].entry++;
      if (j.currency === 'LKR' && j.salary_midpoint) {
        grouped[j.career_category].salaries.push(j.salary_midpoint);
      }
    });

    Object.entries(grouped).sort((a, b) => b[1].count - a[1].count).forEach(([cat, stats]) => {
      const share = ((stats.count / jobs.length) * 100).toFixed(1);
      const entryShare = ((stats.entry / stats.count) * 100).toFixed(1);
      
      let medianStr = 'Negotiable';
      if (stats.salaries.length > 0) {
        const sorted = stats.salaries.sort((a,b)=>a-b);
        const med = sorted[Math.floor(sorted.length/2)];
        medianStr = `LKR ${Math.round(med/1000)}k (n=${stats.salaries.length})`;
      }

      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td><strong>${cat}</strong></td>
        <td>${stats.count}</td>
        <td>${share}%</td>
        <td><span class="badge">${entryShare}%</span></td>
        <td>${medianStr}</td>
        <td>Enterprise / Cloud</td>
      `;
      tbody.appendChild(tr);
    });
  }

  function renderSkillsCharts(jobs, skills) {
    const domainCounts = {};
    skills.forEach(s => {
      domainCounts[s.skill_category] = (domainCounts[s.skill_category] || 0) + 1;
    });
    renderHorizontalBarChart('chart-domain-breakdown', Object.entries(domainCounts).sort((a, b) => b[1] - a[1]), skills.length, '#a855f7');

    // Entry vs Exp comparison
    const entryJobIds = new Set(jobs.filter(j => j.is_entry_level).map(j => j.job_id));
    const entrySkills = skills.filter(s => entryJobIds.has(s.job_id));
    const entryCounts = {};
    entrySkills.forEach(s => { entryCounts[s.skill_name] = (entryCounts[s.skill_name] || 0) + 1; });
    renderHorizontalBarChart('chart-entry-skill-comp', Object.entries(entryCounts).sort((a, b) => b[1] - a[1]).slice(0, 8), Math.max(1, entryJobIds.size), '#38bdf8');
  }

  function renderSalaryCharts(jobs) {
    const lkrJobs = jobs.filter(j => j.currency === 'LKR' && j.salary_midpoint !== null);
    const container = document.getElementById('chart-salary-dist');
    if (!container) return;

    if (lkrJobs.length === 0) {
      container.innerHTML = '<div style="color:var(--text-dim);padding:20px;">No disclosed LKR salaries match active filters.</div>';
    } else {
      const buckets = { '< 150k': 0, '150k - 300k': 0, '300k - 500k': 0, '500k - 750k': 0, '750k+': 0 };
      lkrJobs.forEach(j => {
        const val = j.salary_midpoint;
        if (val < 150000) buckets['< 150k']++;
        else if (val <= 300000) buckets['150k - 300k']++;
        else if (val <= 500000) buckets['300k - 500k']++;
        else if (val <= 750000) buckets['500k - 750k']++;
        else buckets['750k+']++;
      });
      renderHorizontalBarChart('chart-salary-dist', Object.entries(buckets), lkrJobs.length, '#f59e0b');
    }

    // Seniority Salary Table
    const tbody = document.querySelector('#table-seniority-salary tbody');
    if (!tbody) return;
    tbody.innerHTML = '';

    const senGroups = {};
    jobs.filter(j => j.salary_midpoint).forEach(j => {
      if (!senGroups[j.seniority_level]) senGroups[j.seniority_level] = [];
      senGroups[j.seniority_level].push(j);
    });

    ['Intern', 'Junior', 'Mid', 'Senior', 'Lead'].forEach(tier => {
      const items = senGroups[tier] || [];
      if (items.length > 0) {
        const lkrItems = items.filter(x => x.currency === 'LKR');
        let medStr = 'USD Package';
        let rangeStr = '-';
        if (lkrItems.length > 0) {
          const sorted = lkrItems.map(x => x.salary_midpoint).sort((a,b)=>a-b);
          medStr = `LKR ${Math.round(sorted[Math.floor(sorted.length/2)]/1000)}k`;
          rangeStr = `LKR ${Math.round(sorted[0]/1000)}k – ${Math.round(sorted[sorted.length-1]/1000)}k`;
        }
        const tr = document.createElement('tr');
        tr.innerHTML = `
          <td><strong>${tier}</strong></td>
          <td>${items.length}</td>
          <td><span style="color:#34d399;font-weight:600;">${medStr}</span></td>
          <td>${rangeStr}</td>
          <td>${lkrItems.length > 0 ? 'LKR' : 'USD'}</td>
        `;
        tbody.appendChild(tr);
      }
    });
  }

  function renderExperienceCharts(jobs) {
    const buckets = { '0 - 1 Years (Entry)': 0, '2 - 3 Years (Mid)': 0, '4 - 5 Years (Mid-Senior)': 0, '6+ Years (Senior/Lead)': 0 };
    jobs.forEach(j => {
      const e = j.experience_min || 0;
      if (e <= 1) buckets['0 - 1 Years (Entry)']++;
      else if (e <= 3) buckets['2 - 3 Years (Mid)']++;
      else if (e <= 5) buckets['4 - 5 Years (Mid-Senior)']++;
      else buckets['6+ Years (Senior/Lead)']++;
    });
    renderHorizontalBarChart('chart-experience-dist', Object.entries(buckets), jobs.length, '#0ea5e9');
  }

  function renderMacroCharts() {
    const unempRows = data.macro.filter(m => m.indicator_name === 'National Unemployment Rate' && m.quarter === 'Annual');
    const unempArr = unempRows.map(r => [`Year ${r.year}`, r.value]);
    renderHorizontalBarChart('chart-macro-unemp', unempArr, 20, '#d6604d');

    const expRows = data.macro.filter(m => m.indicator_name === 'Telecommunications Computer & Info Export Earnings');
    const expArr = expRows.map(r => [`${r.year} ($M)`, r.value]);
    renderHorizontalBarChart('chart-macro-exports', expArr, 2000, '#10b981');
  }

  function renderMacroSummaryChart(containerId) {
    const expRows = data.macro.filter(m => m.indicator_name === 'Telecommunications Computer & Info Export Earnings');
    const expArr = expRows.slice(-4).map(r => [`ICT ${r.year}`, r.value]);
    renderHorizontalBarChart(containerId, expArr, 2000, '#10b981');
  }

  function renderExplorerTable(jobs) {
    const tbody = document.getElementById('raw-table-body');
    if (!tbody) return;
    tbody.innerHTML = '';

    jobs.forEach(j => {
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td><code>${j.job_id}</code></td>
        <td><strong>${j.original_title}</strong></td>
        <td>${j.company}</td>
        <td><span class="badge">${j.career_category}</span></td>
        <td>${j.seniority_level}</td>
        <td>${j.work_mode}</td>
        <td>${j.original_experience || 'Not Stated'}</td>
        <td>${j.original_salary || 'Negotiable'}</td>
        <td><a href="${j.source_url}" target="_blank" style="color:#818cf8;text-decoration:none;">${j.source} &nearr;</a></td>
      `;
      tbody.appendChild(tr);
    });
  }

  // Initial Boot
  updateDashboard();
});
