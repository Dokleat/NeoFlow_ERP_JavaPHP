<?php include "env.php"; ?>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
  <title>NeoFlow MiniERP</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
  <link href="https://cdn.datatables.net/1.13.8/css/dataTables.bootstrap5.min.css" rel="stylesheet">
  <style>
    :root{
      --bg:#ffffff; --fg:#111111; --card:#f6f6f6; --muted:#6b7280; --accent:#111111;
    }
    .dark{
      --bg:#0d0d0d; --fg:#f3f3f3; --card:#161616; --muted:#9ca3af; --accent:#ffffff;
    }
    body{background:var(--bg); color:var(--fg);}
    .navbar, .card{ background:var(--card); border:1px solid #e5e7eb; }
    .btn-primary{ background:var(--fg); border-color:var(--fg); color:var(--bg); }
    a, .nav-link{ color:var(--fg); }
    table{ color:var(--fg); }
    .form-control,.form-select{ background:var(--bg); color:var(--fg); border-color:#d1d5db; }
    .form-control:focus,.form-select:focus{ box-shadow:none; border-color:#111; }
    .badge{ background:#e5e7eb; color:#111; }
    .low{ background:#fff1f2 !important; }
  </style>
  <script>
    // theme toggle persisted
    (function(){
      const theme = localStorage.getItem('nf_theme') || 'light';
      if(theme==='dark') document.documentElement.classList.add('dark');
      window.toggleTheme = function(){
        document.documentElement.classList.toggle('dark');
        localStorage.setItem('nf_theme', document.documentElement.classList.contains('dark')?'dark':'light');
      }
    })();
  </script>
</head>
<body>
<nav class="navbar navbar-expand-lg mb-4">
  <div class="container-fluid">
    <a class="navbar-brand" href="index.php"><strong>NeoFlow</strong> MiniERP</a>
    <div class="d-flex gap-2 ms-auto">
      <button class="btn btn-sm btn-outline-dark" onclick="toggleTheme()">
        <i class="bi bi-circle-half"></i> Theme
      </button>
    </div>
  </div>
</nav>
<main class="container">
