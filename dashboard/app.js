// ==============================================================================
// TechScape: Dual-Track Analytical Dashboard Logic (dashboard/app.js)
// Comprehensive Baseline vs. Source-Retrieved Live Feed Switching
// ==============================================================================

document.addEventListener('DOMContentLoaded', () => {
  const rawData = window.TECHSCAPE_DATA || { jobs: [], skills: [], macro: [] };

  // Resolve Dual Track Datasets safely
  const baselineDataset = rawData.baseline || {
    jobs: rawData.jobs || [],
    skills: rawData.skills || [],
    metadata: {
      name: "Verified Real Sample",
      sample_size: (rawData.jobs || []).length,
      academic_status: "Frozen Empirical Corpus"
    }
  };

  const liveDataset = rawData.live_feed || {
    jobs: [],
    skills: [],
    metadata: {
      retrieved_at: "Not Yet Sourced",
      total_retrieved: 0,
      source_counts: {},
      mode: "Periodic Public Web Retrieval"
    }
  };

  const macroDataset = rawData.macro || [];

  // State
  let activeTab = 'overview';
  let activeDatasetMode = 'baseline'; // 'baseline' | 'live' | 'combined'

  let filterState = {
    dateWindow: 'ALL',
    career: 'ALL',
    seniority: 'ALL',
    workMode: 'ALL',
    searchQuery: '',
    sortOrder: 'date-desc'
  };

  // Elements
  const navItems = document.querySelectorAll('.nav-item');
  const tabPanels = document.querySelectorAll('.tab-panel');
  const pageTitle = document.getElementById('page-title');
  const pageSubtitle = document.getElementById('page-subtitle');
  
  const filterDate = document.getElementById('filter-date');
  const filterCareer = document.getElementById('filter-career');
  const filterSeniority = document.getElementById('filter-seniority');
  const filterMode = document.getElementById('filter-mode');
  const btnReset = document.getElementById('btn-reset-filters');

  const explorerSearch = document.getElementById('explorer-search');
  const explorerSort = document.getElementById('explorer-sort');
  const explorerCount = document.getElementById('explorer-record-count');

  // Dataset Switcher Elements
  const btnModeBaseline = document.getElementById('btn-mode-baseline');
  const btnModeLive = document.getElementById('btn-mode-live');
  const btnModeCombined = document.getElementById('btn-mode-combined');
  const btnLiveCount = document.getElementById('btn-live-count');

  const metaDatasetMode = document.getElementById('meta-dataset-mode');
  const metaPostingWindow = document.getElementById('meta-posting-window');
  const metaRetrievedChip = document.getElementById('meta-retrieved-chip');
  const metaRetrievedTime = document.getElementById('meta-retrieved-time');
  const mobileDatasetBadge = document.getElementById('mobile-dataset-badge');
  const sidebarGovBadge = document.getElementById('sidebar-gov-badge');
  const govBadgeTitle = document.getElementById('gov-badge-title');
  const govBadgeSubtitle = document.getElementById('gov-badge-subtitle');

  // Mobile Drawer Navigation Elements
  const sidebar = document.getElementById('sidebar');
  const mobileMenuToggle = document.getElementById('mobile-menu-toggle');
  const sidebarCloseBtn = document.getElementById('sidebar-close-btn');
  const sidebarBackdrop = document.getElementById('sidebar-backdrop');

  // Modal Elements
  const jobModal = document.getElementById('job-detail-modal');
  const modalCloseBtn = document.getElementById('modal-close-btn');
  const modalDoneBtn = document.getElementById('modal-done-btn');

  // Update Live Count Badge in button
  if (btnLiveCount && liveDataset.jobs) {
    btnLiveCount.textContent = `n=${liveDataset.jobs.length}`;
  }

  // Mobile Menu Helpers
  function openMobileSidebar() {
    if (sidebar) sidebar.classList.add('open');
    if (sidebarBackdrop) sidebarBackdrop.classList.add('open');
    document.body.style.overflow = 'hidden';
  }

  function closeMobileSidebar() {
    if (sidebar) sidebar.classList.remove('open');
    if (sidebarBackdrop) sidebarBackdrop.classList.remove('open');
    document.body.style.overflow = '';
  }

  if (mobileMenuToggle) mobileMenuToggle.addEventListener('click', openMobileSidebar);
  if (sidebarCloseBtn) sidebarCloseBtn.addEventListener('click', closeMobileSidebar);
  if (sidebarBackdrop) sidebarBackdrop.addEventListener('click', closeMobileSidebar);

  window.addEventListener('resize', () => {
    if (window.innerWidth > 768) closeMobileSidebar();
  });

  // Current Dataset Accessor
  function getActiveDataset() {
    if (activeDatasetMode === 'live') {
      return {
        jobs: liveDataset.jobs || [],
        skills: liveDataset.skills || [],
        metadata: liveDataset.metadata
      };
    } else if (activeDatasetMode === 'combined') {
      const combinedJobs = [...(baselineDataset.jobs || []), ...(liveDataset.jobs || [])];
      const combinedSkills = [...(baselineDataset.skills || []), ...(liveDataset.skills || [])];
      return {
        jobs: combinedJobs,
        skills: combinedSkills,
        metadata: { name: "Combined Dataset Stream" }
      };
    }
    // Default: Baseline
    return {
      jobs: baselineDataset.jobs || [],
      skills: baselineDataset.skills || [],
      metadata: baselineDataset.metadata
    };
  }

  // Dataset Switcher Wiring
  function switchDatasetMode(mode) {
    activeDatasetMode = mode;
    [btnModeBaseline, btnModeLive, btnModeCombined].forEach(b => {
      if (b) b.classList.remove('active');
    });

    if (mode === 'baseline' && btnModeBaseline) btnModeBaseline.classList.add('active');
    if (mode === 'live' && btnModeLive) btnModeLive.classList.add('active');
    if (mode === 'combined' && btnModeCombined) btnModeCombined.classList.add('active');

    // Update Header and Badges
    const ds = getActiveDataset();
    if (metaDatasetMode) {
      if (mode === 'baseline') metaDatasetMode.textContent = "Verified Baseline (Academic Corpus n=80)";
      else if (mode === 'live') metaDatasetMode.textContent = `Source-Retrieved Live Feed (n=${ds.jobs.length})`;
      else metaDatasetMode.textContent = `Combined Stream (n=${ds.jobs.length})`;
    }

    if (mobileDatasetBadge) {
      if (mode === 'baseline') mobileDatasetBadge.textContent = "Baseline (n=80)";
      else if (mode === 'live') mobileDatasetBadge.textContent = `Live Feed (n=${ds.jobs.length})`;
      else mobileDatasetBadge.textContent = `Combined (n=${ds.jobs.length})`;
    }

    if (govBadgeTitle) {
      if (mode === 'baseline') {
        govBadgeTitle.textContent = "VERIFIED BASELINE CORPUS";
        if (govBadgeSubtitle) govBadgeSubtitle.textContent = "Aug 10 – Aug 26, 2026 (n=80)";
      } else if (mode === 'live') {
        govBadgeTitle.textContent = "SOURCE-RETRIEVED FEED";
        if (govBadgeSubtitle) govBadgeSubtitle.textContent = `Retrieved: ${liveDataset.metadata.retrieved_at || 'Recent'}`;
      } else {
        govBadgeTitle.textContent = "COMBINED MARKET STREAM";
        if (govBadgeSubtitle) govBadgeSubtitle.textContent = `Total Sample: n=${ds.jobs.length}`;
      }
    }

    if (metaRetrievedChip) {
      if (mode === 'live' && liveDataset.metadata && liveDataset.metadata.retrieved_at) {
        metaRetrievedChip.style.display = 'inline-flex';
        if (metaRetrievedTime) metaRetrievedTime.textContent = liveDataset.metadata.retrieved_at;
      } else {
        metaRetrievedChip.style.display = 'none';
      }
    }

    // Refresh Career Filter Options for the active dataset
    populateCareerFilter();
    updateDashboard();
  }

  if (btnModeBaseline) btnModeBaseline.addEventListener('click', () => switchDatasetMode('baseline'));
  if (btnModeLive) btnModeLive.addEventListener('click', () => switchDatasetMode('live'));
  if (btnModeCombined) btnModeCombined.addEventListener('click', () => switchDatasetMode('combined'));

  // Populate Career Filter Options dynamically
  function populateCareerFilter() {
    const ds = getActiveDataset();
    const currentVal = filterCareer.value;
    filterCareer.innerHTML = '<option value="ALL">All Categories</option>';
    const uniqueCareers = Array.from(new Set(ds.jobs.map(j => j.career_category))).filter(Boolean).sort();
    uniqueCareers.forEach(c => {
      const opt = document.createElement('option');
      opt.value = c;
      opt.textContent = c;
      filterCareer.appendChild(opt);
    });
    if (uniqueCareers.includes(currentVal)) {
      filterCareer.value = currentVal;
    }
  }

  // Tab Navigation Handling
  const tabMetadata = {
    overview: { 
      title: "Executive Labour Market Overview", 
      subtitle: "Empirical insights from verified Sri Lankan IT job postings and national employment indicators" 
    },
    careers: { 
      title: "Career Category Dynamics (RQ2)", 
      subtitle: "Market share and specialization demand across standardized career tracks" 
    },
    skills: { 
      title: "Technical Skills Demand (RQ3)", 
      subtitle: "Penetration rates across programming languages, cloud platforms, and tooling" 
    },
    salary: { 
      title: "Compensation & Currency Dynamics (RQ6)", 
      subtitle: "Observed LKR distributions, USD-pegged structures, and seniority benchmarks" 
    },
    experience: { 
      title: "Experience Requirements & Accessibility (RQ4, RQ5)", 
      subtitle: "Minimum experience spread and entry-level accessibility ratios in active postings" 
    },
    macro: { 
      title: "Macroeconomic Context (RQ7)", 
      subtitle: "DCS National/Youth Unemployment (2016–2025) and CBSL ICT Service Export Earnings" 
    },
    advisory: { 
      title: "Student Insights & Career Guidance", 
      subtitle: "Actionable, evidence-backed advice for Sri Lankan IT undergraduates" 
    },
    explorer: { 
      title: "Empirical Postings & Audit Registry", 
      subtitle: "Record explorer with publication dates, source timestamps, and direct portal verification" 
    }
  };

  navItems.forEach(btn => {
    btn.addEventListener('click', () => {
      const target = btn.getAttribute('data-tab');
      if (target === activeTab) {
        closeMobileSidebar();
        return;
      }

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

      closeMobileSidebar();
      window.scrollTo({ top: 0, behavior: 'smooth' });
      renderCurrentTab();
    });
  });

  // Filter Listeners
  if (filterDate) {
    filterDate.addEventListener('change', (e) => { 
      filterState.dateWindow = e.target.value; 
      updateDashboard(); 
    });
  }

  filterCareer.addEventListener('change', (e) => { filterState.career = e.target.value; updateDashboard(); });
  filterSeniority.addEventListener('change', (e) => { filterState.seniority = e.target.value; updateDashboard(); });
  filterMode.addEventListener('change', (e) => { filterState.workMode = e.target.value; updateDashboard(); });
  
  if (explorerSearch) {
    explorerSearch.addEventListener('input', (e) => {
      filterState.searchQuery = e.target.value.toLowerCase().trim();
      renderExplorerTable(getFilteredJobs());
    });
  }

  if (explorerSort) {
    explorerSort.addEventListener('change', (e) => {
      filterState.sortOrder = e.target.value;
      renderExplorerTable(getFilteredJobs());
    });
  }

  btnReset.addEventListener('click', () => {
    filterState = { 
      dateWindow: 'ALL', 
      career: 'ALL', 
      seniority: 'ALL', 
      workMode: 'ALL', 
      searchQuery: '', 
      sortOrder: 'date-desc' 
    };
    if (filterDate) filterDate.value = 'ALL';
    filterCareer.value = 'ALL';
    filterSeniority.value = 'ALL';
    filterMode.value = 'ALL';
    if (explorerSearch) explorerSearch.value = '';
    if (explorerSort) explorerSort.value = 'date-desc';
    updateDashboard();
  });

  // Filter evaluation
  function getFilteredJobs() {
    const ds = getActiveDataset();
    return ds.jobs.filter(job => {
      if (filterState.dateWindow === 'LIVE') {
        if (!job.date_posted || !job.date_posted.startsWith('2026-09')) return false;
      } else if (filterState.dateWindow === 'BASELINE') {
        if (!job.date_posted || !job.date_posted.startsWith('2026-08')) return false;
      } else if (filterState.dateWindow === 'LATE') {
        if (!job.date_posted || job.date_posted < '2026-08-20') return false;
      } else if (filterState.dateWindow === 'MID') {
        if (!job.date_posted || job.date_posted >= '2026-08-20') return false;
      }

      if (filterState.career !== 'ALL' && job.career_category !== filterState.career) return false;
      if (filterState.seniority !== 'ALL' && job.seniority_level !== filterState.seniority) return false;
      if (filterState.workMode !== 'ALL' && job.work_mode !== filterState.workMode) return false;
      return true;
    });
  }

  function formatDate(dStr) {
    if (!dStr) return 'N/A';
    const parts = dStr.split('-');
    if (parts.length !== 3) return dStr;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const monthName = months[parseInt(parts[1], 10) - 1] || parts[1];
    return `${parts[2]} ${monthName} ${parts[0]}`;
  }

  function formatShortDate(dStr) {
    if (!dStr) return '';
    const parts = dStr.split('-');
    if (parts.length !== 3) return dStr;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const monthName = months[parseInt(parts[1], 10) - 1] || parts[1];
    return `${monthName} ${parseInt(parts[2], 10)}`;
  }

  function updateDashboard() {
    const filteredJobs = getFilteredJobs();
    const totalCount = filteredJobs.length;

    // Determine dynamic date boundaries
    const dates = filteredJobs.map(j => j.date_posted).filter(Boolean).sort();
    const minDate = dates.length > 0 ? dates[0] : '2026-08-10';
    const maxDate = dates.length > 0 ? dates[dates.length - 1] : '2026-08-28';
    const employers = new Set(filteredJobs.map(j => j.company)).size;

    // Update Header Metadata Chip
    if (metaPostingWindow) {
      metaPostingWindow.textContent = `${formatDate(minDate)} – ${formatDate(maxDate)}`;
    }

    // Update KPI Ribbon
    const kpiTotalJobs = document.getElementById('kpi-total-jobs');
    if (kpiTotalJobs) kpiTotalJobs.textContent = totalCount;

    const kpiDateRange = document.getElementById('kpi-date-range');
    if (kpiDateRange) {
      kpiDateRange.textContent = `${formatShortDate(minDate)} – ${formatShortDate(maxDate)} (${employers} Employers)`;
    }

    const entryCount = filteredJobs.filter(j => j.is_entry_level === true || j.is_entry_level === 'true').length;
    const entryPct = totalCount > 0 ? ((entryCount / totalCount) * 100).toFixed(1) : '0.0';
    const kpiEntryPct = document.getElementById('kpi-entry-pct');
    if (kpiEntryPct) kpiEntryPct.textContent = `${entryPct}%`;

    const lkrJobs = filteredJobs.filter(j => j.currency === 'LKR' && j.salary_midpoint !== null && j.salary_midpoint !== undefined && j.salary_midpoint !== "");
    const kpiMedianSalary = document.getElementById('kpi-median-salary');
    if (kpiMedianSalary) {
      if (lkrJobs.length > 0) {
        const sortedMids = lkrJobs.map(j => Number(j.salary_midpoint)).sort((a, b) => a - b);
        const midIdx = Math.floor(sortedMids.length / 2);
        const medianLKR = sortedMids.length % 2 !== 0 ? sortedMids[midIdx] : (sortedMids[midIdx - 1] + sortedMids[midIdx]) / 2;
        kpiMedianSalary.textContent = `LKR ${Math.round(medianLKR / 1000)}k`;
      } else {
        kpiMedianSalary.textContent = 'Negotiable';
      }
    }

    const disclosedJobs = filteredJobs.filter(j => j.salary_disclosed === true || j.salary_disclosed === 'true' || (j.salary_midpoint !== null && j.salary_midpoint !== ""));
    const usdCount = filteredJobs.filter(j => j.currency === 'USD').length;
    const usdPct = disclosedJobs.length > 0 ? ((usdCount / disclosedJobs.length) * 100).toFixed(1) : (totalCount > 0 ? ((usdCount / totalCount) * 100).toFixed(1) : '0.0');
    const kpiUsdRatio = document.getElementById('kpi-usd-ratio');
    if (kpiUsdRatio) kpiUsdRatio.textContent = `${usdPct}%`;

    renderCurrentTab();
  }

  function renderCurrentTab() {
    const ds = getActiveDataset();
    const jobs = getFilteredJobs();
    const jobIds = new Set(jobs.map(j => j.job_id));
    const skills = ds.skills.filter(s => jobIds.has(s.job_id));

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
    // 1. Daily Posting Velocity Timeline Chart
    renderPostingTimeline(jobs);

    // 2. Career Distribution
    const careerCounts = {};
    jobs.forEach(j => { careerCounts[j.career_category] = (careerCounts[j.career_category] || 0) + 1; });
    const careerArr = Object.entries(careerCounts).sort((a, b) => b[1] - a[1]);
    renderHorizontalBarChart('chart-career-dist', careerArr, jobs.length, '#8DB4A2');

    // 3. Top Skills
    const skillCounts = {};
    skills.forEach(s => { skillCounts[s.skill_name] = (skillCounts[s.skill_name] || 0) + 1; });
    const topSkillsArr = Object.entries(skillCounts).sort((a, b) => b[1] - a[1]).slice(0, 10);
    renderHorizontalBarChart('chart-top-skills', topSkillsArr, jobs.length, '#06274C');

    // 4. Work Mode
    const modeCounts = {};
    jobs.forEach(j => { modeCounts[j.work_mode] = (modeCounts[j.work_mode] || 0) + 1; });
    const modeArr = Object.entries(modeCounts).sort((a, b) => b[1] - a[1]);
    renderHorizontalBarChart('chart-work-mode', modeArr, jobs.length, '#6d9a87');

    // 5. Macro Quick View
    renderMacroSummaryChart('chart-macro-summary');
  }

  function renderPostingTimeline(jobs) {
    const container = document.getElementById('chart-posting-timeline');
    const badgeCount = document.getElementById('badge-timeline-count');
    if (!container) return;

    if (jobs.length === 0) {
      container.innerHTML = '<div style="color:var(--text-dim);padding:24px;text-align:center;">No job postings match the active filter criteria.</div>';
      if (badgeCount) badgeCount.textContent = '0 Postings';
      return;
    }

    const dateMap = {};
    jobs.forEach(j => {
      const d = j.date_posted;
      if (d) dateMap[d] = (dateMap[d] || 0) + 1;
    });

    const sortedDates = Object.keys(dateMap).sort();
    if (badgeCount) {
      badgeCount.textContent = `${jobs.length} Postings across ${sortedDates.length} Active Dates`;
    }

    const maxCount = Math.max(...Object.values(dateMap), 1);

    let html = '<div class="timeline-grid">';
    sortedDates.forEach(dStr => {
      const count = dateMap[dStr];
      const heightPct = Math.max(15, Math.round((count / maxCount) * 100));
      const shortLabel = formatShortDate(dStr);

      html += `
        <div class="timeline-col" title="${dStr}: ${count} posting(s)">
          <div class="timeline-bar-wrapper">
            <div class="timeline-bar" style="height: ${heightPct}%;">
              <span class="timeline-bar-count">${count}</span>
            </div>
          </div>
          <span class="timeline-label">${shortLabel}</span>
        </div>
      `;
    });
    html += '</div>';
    container.innerHTML = html;
  }

  function renderHorizontalBarChart(containerId, dataArr, total, barColor) {
    const container = document.getElementById(containerId);
    if (!container) return;
    container.innerHTML = '';

    if (dataArr.length === 0) {
      container.innerHTML = '<div style="color:#7f95a5;padding:20px;">No records match the active filter criteria.</div>';
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
      if (j.is_entry_level === true || j.is_entry_level === 'true') grouped[j.career_category].entry++;
      if (j.currency === 'LKR' && j.salary_midpoint) {
        grouped[j.career_category].salaries.push(j.salary_midpoint);
      }
    });

    Object.entries(grouped).sort((a, b) => b[1].count - a[1].count).forEach(([cat, stats]) => {
      const share = ((stats.count / Math.max(1, jobs.length)) * 100).toFixed(1);
      const entryShare = ((stats.entry / Math.max(1, stats.count)) * 100).toFixed(1);
      
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
        <td><span class="date-badge">${activeDatasetMode.toUpperCase()}</span></td>
      `;
      tbody.appendChild(tr);
    });
  }

  function renderSkillsCharts(jobs, skills) {
    const domainCounts = {};
    skills.forEach(s => {
      domainCounts[s.skill_category] = (domainCounts[s.skill_category] || 0) + 1;
    });
    renderHorizontalBarChart('chart-domain-breakdown', Object.entries(domainCounts).sort((a, b) => b[1] - a[1]), Math.max(1, skills.length), '#8DB4A2');

    const entryJobIds = new Set(jobs.filter(j => j.is_entry_level === true || j.is_entry_level === 'true').map(j => j.job_id));
    const entrySkills = skills.filter(s => entryJobIds.has(s.job_id));
    const entryCounts = {};
    entrySkills.forEach(s => { entryCounts[s.skill_name] = (entryCounts[s.skill_name] || 0) + 1; });
    renderHorizontalBarChart('chart-entry-skill-comp', Object.entries(entryCounts).sort((a, b) => b[1] - a[1]).slice(0, 8), Math.max(1, entryJobIds.size), '#06274C');
  }

  function renderSalaryCharts(jobs) {
    const lkrJobs = jobs.filter(j => j.currency === 'LKR' && j.salary_midpoint !== null && j.salary_midpoint !== "");
    const container = document.getElementById('chart-salary-dist');
    if (!container) return;

    if (lkrJobs.length === 0) {
      container.innerHTML = '<div style="color:var(--text-dim);padding:20px;">No disclosed LKR salaries match active filters.</div>';
    } else {
      const buckets = { '< 150k': 0, '150k - 300k': 0, '300k - 500k': 0, '500k - 750k': 0, '750k+': 0 };
      lkrJobs.forEach(j => {
        const val = Number(j.salary_midpoint);
        if (val < 150000) buckets['< 150k']++;
        else if (val <= 300000) buckets['150k - 300k']++;
        else if (val <= 500000) buckets['300k - 500k']++;
        else if (val <= 750000) buckets['500k - 750k']++;
        else buckets['750k+']++;
      });
      renderHorizontalBarChart('chart-salary-dist', Object.entries(buckets), lkrJobs.length, '#B3C7AF');
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
          const sorted = lkrItems.map(x => Number(x.salary_midpoint)).sort((a,b)=>a-b);
          medStr = `LKR ${Math.round(sorted[Math.floor(sorted.length/2)]/1000)}k`;
          rangeStr = `LKR ${Math.round(sorted[0]/1000)}k – ${Math.round(sorted[sorted.length-1]/1000)}k`;
        }
        const tr = document.createElement('tr');
        tr.innerHTML = `
          <td><strong>${tier}</strong></td>
          <td>${items.length}</td>
          <td><span style="color:#2a8f60;font-weight:600;">${medStr}</span></td>
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
      const e = Number(j.experience_min) || 0;
      if (e <= 1) buckets['0 - 1 Years (Entry)']++;
      else if (e <= 3) buckets['2 - 3 Years (Mid)']++;
      else if (e <= 5) buckets['4 - 5 Years (Mid-Senior)']++;
      else buckets['6+ Years (Senior/Lead)']++;
    });
    renderHorizontalBarChart('chart-experience-dist', Object.entries(buckets), Math.max(1, jobs.length), '#06274C');
  }

  function renderMacroCharts() {
    const unempRows = macroDataset.filter(m => m.indicator_name === 'National Unemployment Rate' && m.quarter === 'Annual');
    const unempArr = unempRows.map(r => [`Year ${r.year}`, Number(r.value)]);
    renderHorizontalBarChart('chart-macro-unemp', unempArr, 20, '#c04b4b');

    const expRows = macroDataset.filter(m => m.indicator_name === 'Telecommunications Computer & Info Export Earnings');
    const expArr = expRows.map(r => [`Year ${r.year} ($M)`, Number(r.value)]);
    renderHorizontalBarChart('chart-macro-exports', expArr, 2000, '#8DB4A2');
  }

  function renderMacroSummaryChart(containerId) {
    const expRows = macroDataset.filter(m => m.indicator_name === 'Telecommunications Computer & Info Export Earnings');
    const expArr = expRows.slice(-4).map(r => [`ICT ${r.year}`, Number(r.value)]);
    renderHorizontalBarChart(containerId, expArr, 2000, '#8DB4A2');
  }

  // --- Smart Live Search Query Sanitizer ---
  function getCleanSearchTokens(job) {
    // 1. Clean Company Name
    let company = (job.company || '')
      .replace(/\(.*?\)/g, '') // remove parentheticals
      .replace(/\b(Sri Lanka|Lanka|Holdings|International|Technologies|Solutions|PLC|ESP|IT|Pvt Ltd|Ltd)\b/gi, '') // remove corporate/location suffixes
      .replace(/[^\w\s]/g, ' ') // remove special chars
      .replace(/\s+/g, ' ')
      .trim();

    // 2. Clean Job Title
    let rawTitle = job.original_title || job.job_title || '';
    let title = rawTitle
      .replace(/\(.*?\)/g, '') // remove parentheticals like (Java / Spring Boot)
      .replace(/\s*[-/|].*$/, '') // remove secondary tech stack tags after hyphens or slashes
      .replace(/[^\w\s]/g, ' ') // remove special chars
      .replace(/\s+/g, ' ')
      .trim();

    // Fallbacks
    if (!title || title.length < 3) {
      title = (job.job_title || job.original_title || '').replace(/[^\w\s]/g, ' ').replace(/\s+/g, ' ').trim();
    }
    if (!company) {
      company = (job.company || '').replace(/[^\w\s]/g, ' ').replace(/\s+/g, ' ').trim();
    }

    return {
      cleanCompany: company,
      cleanTitle: title
    };
  }

  function buildLinkedInLiveSearchUrl(job) {
    const { cleanCompany, cleanTitle } = getCleanSearchTokens(job);
    const query = `${cleanTitle} ${cleanCompany}`.trim();
    return `https://www.linkedin.com/jobs/search/?keywords=${encodeURIComponent(query)}&location=Sri+Lanka`;
  }

  function buildGoogleJobsLiveSearchUrl(job) {
    const { cleanCompany, cleanTitle } = getCleanSearchTokens(job);
    const query = `${cleanCompany} ${cleanTitle} jobs Sri Lanka`.trim();
    return `https://www.google.com/search?q=${encodeURIComponent(query)}`;
  }

  function buildTopJobsLiveSearchUrl(job) {
    const { cleanCompany, cleanTitle } = getCleanSearchTokens(job);
    const query = `site:topjobs.lk ${cleanCompany} ${cleanTitle}`.trim();
    return `https://www.google.com/search?q=${encodeURIComponent(query)}`;
  }

  // --- Explorer Table & Search & Sorting ---

  function renderExplorerTable(jobs) {
    const ds = getActiveDataset();
    const tbody = document.getElementById('raw-table-body');
    if (!tbody) return;
    tbody.innerHTML = '';

    // Apply Search Query
    let filtered = jobs;
    if (filterState.searchQuery) {
      const q = filterState.searchQuery;
      filtered = filtered.filter(j => {
        return (
          (j.job_id && j.job_id.toLowerCase().includes(q)) ||
          (j.original_title && j.original_title.toLowerCase().includes(q)) ||
          (j.company && j.company.toLowerCase().includes(q)) ||
          (j.career_category && j.career_category.toLowerCase().includes(q)) ||
          (j.date_posted && j.date_posted.includes(q)) ||
          (j.collection_date && j.collection_date.includes(q)) ||
          (j.skill_names_concat && j.skill_names_concat.toLowerCase().includes(q))
        );
      });
    }

    // Apply Sorting
    filtered.sort((a, b) => {
      if (filterState.sortOrder === 'date-desc') {
        return (b.date_posted || '').localeCompare(a.date_posted || '');
      } else if (filterState.sortOrder === 'date-asc') {
        return (a.date_posted || '').localeCompare(b.date_posted || '');
      } else if (filterState.sortOrder === 'coll-desc') {
        return (b.collection_date || '').localeCompare(a.collection_date || '');
      } else if (filterState.sortOrder === 'title-asc') {
        return (a.original_title || '').localeCompare(b.original_title || '');
      } else if (filterState.sortOrder === 'company-asc') {
        return (a.company || '').localeCompare(b.company || '');
      }
      return 0;
    });

    if (explorerCount) {
      explorerCount.textContent = `Showing ${filtered.length} of ${ds.jobs.length} postings in [${activeDatasetMode.toUpperCase()}] layer`;
    }

    if (filtered.length === 0) {
      tbody.innerHTML = `
        <tr>
          <td colspan="11" style="text-align:center;padding:30px;color:var(--text-dim);">
            No job postings match the active search and filter criteria in the <strong>${activeDatasetMode}</strong> layer.
          </td>
        </tr>
      `;
      return;
    }

    filtered.forEach(j => {
      // Build Verification Link
      let linkHtml = '';
      const src = j.source || 'TopJobs_LK';

      if (src.toLowerCase().includes('topjobs')) {
        if (j.source_url && j.source_url.includes('JobAdvertismentServlet')) {
          linkHtml = `<a href="${j.source_url}" target="_blank" class="portal-link portal-topjobs" title="View active TopJobs advert">TopJobs LK &nearr;</a>`;
        } else {
          const topJobsSearch = buildTopJobsLiveSearchUrl(j);
          linkHtml = `<a href="${topJobsSearch}" target="_blank" class="portal-link portal-topjobs" title="Search archived TopJobs notice">TopJobs Archive &nearr;</a>`;
        }
      } else if (src.toLowerCase().includes('itpro')) {
        linkHtml = `<a href="${j.source_url}" target="_blank" class="portal-link portal-itpro" title="View direct ITPro listing">ITPro LK &nearr;</a>`;
      } else if (src.toLowerCase().includes('linkedin')) {
        const liveSearchUrl = buildLinkedInLiveSearchUrl(j);
        linkHtml = `<a href="${liveSearchUrl}" target="_blank" class="portal-link portal-linkedin" title="Search live vacancy on LinkedIn">Live Search &nearr;</a>`;
      } else {
        linkHtml = `<a href="${j.source_url}" target="_blank" class="portal-link portal-topjobs">Source Link &nearr;</a>`;
      }

      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td><code>${j.job_id}</code></td>
        <td><span class="date-badge">📅 ${j.date_posted || 'N/A'}</span></td>
        <td><strong>${j.original_title || j.job_title}</strong></td>
        <td>${j.company}</td>
        <td><span class="badge">${j.career_category}</span></td>
        <td>${j.seniority_level}</td>
        <td>${j.work_mode}</td>
        <td><span class="coll-date-badge">🕒 ${j.collection_date || 'N/A'}</span></td>
        <td>${j.original_salary || 'Negotiable'}</td>
        <td>${linkHtml}</td>
        <td><button class="audit-btn" data-jobid="${j.job_id}">Inspect</button></td>
      `;

      const btn = tr.querySelector('.audit-btn');
      if (btn) {
        btn.addEventListener('click', () => openJobModal(j));
      }

      tbody.appendChild(tr);
    });
  }

  // --- Modal Handler ---

  function openJobModal(job) {
    const ds = getActiveDataset();
    if (!jobModal) return;

    document.getElementById('modal-job-title').textContent = job.original_title || job.job_title;
    document.getElementById('modal-company').textContent = `${job.company} · ${job.location || 'Sri Lanka'}`;
    
    document.getElementById('modal-date-posted').textContent = formatDate(job.date_posted);
    document.getElementById('modal-date-collected').textContent = formatDate(job.collection_date);
    document.getElementById('modal-quarter').textContent = job.posting_year_quarter || '2026-Q3';
    document.getElementById('modal-source').textContent = job.source;

    document.getElementById('modal-job-id').textContent = job.job_id;
    document.getElementById('modal-category').textContent = job.career_category;
    document.getElementById('modal-seniority').textContent = job.seniority_level;
    document.getElementById('modal-mode').textContent = job.work_mode;
    document.getElementById('modal-experience').textContent = job.original_experience || 'Not Stated';
    document.getElementById('modal-salary').textContent = job.original_salary || 'Negotiable / Undisclosed';

    // Action Links
    const linkedinBtn = document.getElementById('modal-linkedin-link');
    const googleBtn = document.getElementById('modal-google-link');
    const sourceLink = document.getElementById('modal-source-link');

    if (linkedinBtn) {
      linkedinBtn.href = buildLinkedInLiveSearchUrl(job);
    }
    if (googleBtn) {
      googleBtn.href = buildGoogleJobsLiveSearchUrl(job);
    }
    if (sourceLink) {
      if (job.source_url && job.source_url.includes('JobAdvertismentServlet')) {
        sourceLink.href = job.source_url;
        sourceLink.style.display = 'inline-flex';
        sourceLink.textContent = "Direct TopJobs Advert ↗";
      } else if (job.source && job.source.toLowerCase().includes('itpro')) {
        sourceLink.href = job.source_url || '#';
        sourceLink.style.display = 'inline-flex';
        sourceLink.textContent = "Direct ITPro Listing ↗";
      } else if (job.source && job.source.toLowerCase().includes('topjobs')) {
        sourceLink.href = buildTopJobsLiveSearchUrl(job);
        sourceLink.style.display = 'inline-flex';
        sourceLink.textContent = "Search TopJobs Archive ↗";
      } else {
        sourceLink.href = job.source_url || '#';
        sourceLink.style.display = 'inline-flex';
        sourceLink.textContent = `Direct ${job.source || 'Source'} Link ↗`;
      }
    }

    // Populate skills tags
    const skillsContainer = document.getElementById('modal-skills-list');
    if (skillsContainer) {
      skillsContainer.innerHTML = '';
      const jobSkills = ds.skills.filter(s => s.job_id === job.job_id);
      if (jobSkills.length > 0) {
        jobSkills.forEach(s => {
          const chip = document.createElement('span');
          chip.className = 'skill-chip';
          chip.textContent = `${s.skill_name} (${s.skill_category})`;
          skillsContainer.appendChild(chip);
        });
      } else if (job.skill_names_concat) {
        job.skill_names_concat.split(';').forEach(s => {
          const chip = document.createElement('span');
          chip.className = 'skill-chip';
          chip.textContent = s.trim();
          skillsContainer.appendChild(chip);
        });
      } else {
        skillsContainer.innerHTML = '<span style="color:var(--text-dim);font-size:0.8rem;">No explicit technical skills tagged.</span>';
      }
    }

    jobModal.classList.add('open');
    document.body.style.overflow = 'hidden';
  }

  function closeJobModal() {
    if (jobModal) jobModal.classList.remove('open');
    document.body.style.overflow = '';
  }

  if (modalCloseBtn) modalCloseBtn.addEventListener('click', closeJobModal);
  if (modalDoneBtn) modalDoneBtn.addEventListener('click', closeJobModal);
  if (jobModal) {
    jobModal.addEventListener('click', (e) => {
      if (e.target === jobModal) closeJobModal();
    });
  }

  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      if (jobModal && jobModal.classList.contains('open')) closeJobModal();
      closeMobileSidebar();
    }
  });

  // Initial Boot
  switchDatasetMode('baseline');
});
