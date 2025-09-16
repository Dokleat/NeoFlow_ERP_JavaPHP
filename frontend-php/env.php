<?php
$API_BASE   = getenv("API_BASE") ?: "http://localhost:8080/api";
$API_ORDERS = $API_BASE . "/orders";
$API_PRODUCTS = $API_BASE . "/products";
$API_CUSTOMERS = $API_BASE . "/customers";