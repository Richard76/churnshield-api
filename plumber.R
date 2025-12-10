# ChurnShield API - R Demo
# A simple Plumber API for churn risk scoring

library(plumber)

#* @apiTitle ChurnShield API
#* @apiDescription R-powered churn risk scoring demo for Taskomation

#* Health check endpoint
#* @get /health
function() {
  list(
    status = "ok",
    service = "ChurnShield API",
    version = "1.0.0",
    timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S UTC"),
    powered_by = "R + Plumber"
  )
}

#* Calculate health score from customer metrics
#* @param days_inactive Days since last login (0-365)
#* @param login_count Total logins in last 30 days (0-100)
#* @param support_tickets Support tickets in last 30 days (0-20)
#* @param feature_adoption Features adopted (0-10)
#* @post /score
function(days_inactive = 7, login_count = 10, support_tickets = 0, feature_adoption = 5) {
  # Convert to numeric
  days_inactive <- as.numeric(days_inactive)
  login_count <- as.numeric(login_count)
  support_tickets <- as.numeric(support_tickets)
  feature_adoption <- as.numeric(feature_adoption)

  # Validate inputs
  if (is.na(days_inactive) || is.na(login_count) || is.na(support_tickets) || is.na(feature_adoption)) {
    return(list(error = "Invalid input - all parameters must be numeric"))
  }

  # Health score calculation (simplified Cox-inspired weights)
  # Higher score = healthier customer
  score <- 100

  # Days inactive penalty (biggest factor)
  score <- score - (days_inactive * 1.5)

  # Login bonus
  score <- score + (login_count * 0.5)

  # Support tickets penalty (early tickets are bad)
  score <- score - (support_tickets * 3)

  # Feature adoption bonus
  score <- score + (feature_adoption * 2)

  # Clamp to 0-100
  score <- max(0, min(100, score))

  # Determine risk level
  risk_level <- if (score < 30) {
    "HIGH"
  } else if (score < 60) {
    "MEDIUM"
  } else {
    "LOW"
  }

  # Calculate churn probability (simplified)
  churn_probability <- round((100 - score) / 100, 2)

  # Survival estimate (days until likely churn)
  survival_days <- if (risk_level == "HIGH") {
    round(30 + (score * 2))
  } else if (risk_level == "MEDIUM") {
    round(90 + (score * 3))
  } else {
    "365+"
  }

  # Recommendations
  recommendations <- c()
  if (days_inactive > 7) {
    recommendations <- c(recommendations, "Send re-engagement email")
  }
  if (support_tickets > 2) {
    recommendations <- c(recommendations, "Schedule customer success call")
  }
  if (feature_adoption < 3) {
    recommendations <- c(recommendations, "Trigger onboarding sequence")
  }
  if (login_count < 5) {
    recommendations <- c(recommendations, "Send usage tips email")
  }
  if (length(recommendations) == 0) {
    recommendations <- c("Customer healthy - maintain relationship")
  }

  list(
    health_score = round(score, 1),
    risk_level = risk_level,
    churn_probability = churn_probability,
    estimated_days_to_churn = survival_days,
    input_metrics = list(
      days_inactive = days_inactive,
      login_count = login_count,
      support_tickets = support_tickets,
      feature_adoption = feature_adoption
    ),
    recommendations = recommendations,
    calculated_at = format(Sys.time(), "%Y-%m-%d %H:%M:%S UTC")
  )
}

#* Get demo customers with pre-calculated scores
#* @get /demo-customers
function() {
  # Fake customer data for demonstration
  customers <- list(
    list(
      id = "cust_001",
      name = "Acme Corp",
      mrr = 299,
      days_inactive = 2,
      login_count = 45,
      support_tickets = 0,
      feature_adoption = 8,
      health_score = 95,
      risk_level = "LOW"
    ),
    list(
      id = "cust_002",
      name = "Beta Industries",
      mrr = 199,
      days_inactive = 14,
      login_count = 8,
      support_tickets = 3,
      feature_adoption = 4,
      health_score = 52,
      risk_level = "MEDIUM"
    ),
    list(
      id = "cust_003",
      name = "Gamma LLC",
      mrr = 499,
      days_inactive = 45,
      login_count = 2,
      support_tickets = 5,
      feature_adoption = 2,
      health_score = 18,
      risk_level = "HIGH"
    ),
    list(
      id = "cust_004",
      name = "Delta Systems",
      mrr = 149,
      days_inactive = 7,
      login_count = 20,
      support_tickets = 1,
      feature_adoption = 6,
      health_score = 74,
      risk_level = "LOW"
    ),
    list(
      id = "cust_005",
      name = "Epsilon Tech",
      mrr = 399,
      days_inactive = 21,
      login_count = 5,
      support_tickets = 4,
      feature_adoption = 3,
      health_score = 35,
      risk_level = "MEDIUM"
    )
  )

  # Calculate total MRR at risk
  high_risk_mrr <- sum(sapply(customers, function(c) {
    if (c$risk_level == "HIGH") c$mrr else 0
  }))

  medium_risk_mrr <- sum(sapply(customers, function(c) {
    if (c$risk_level == "MEDIUM") c$mrr else 0
  }))

  list(
    summary = list(
      total_customers = length(customers),
      high_risk_count = sum(sapply(customers, function(c) c$risk_level == "HIGH")),
      medium_risk_count = sum(sapply(customers, function(c) c$risk_level == "MEDIUM")),
      low_risk_count = sum(sapply(customers, function(c) c$risk_level == "LOW")),
      mrr_at_high_risk = paste0("$", high_risk_mrr),
      mrr_at_medium_risk = paste0("$", medium_risk_mrr)
    ),
    customers = customers
  )
}

#* API info and documentation
#* @get /
function() {
  list(
    name = "ChurnShield API",
    description = "R-powered churn risk scoring for SaaS companies",
    version = "1.0.0",
    endpoints = list(
      list(method = "GET", path = "/health", description = "Health check"),
      list(method = "POST", path = "/score", description = "Calculate health score"),
      list(method = "GET", path = "/demo-customers", description = "View demo customer data")
    ),
    example_score_request = list(
      method = "POST",
      url = "/score",
      body = list(
        days_inactive = 7,
        login_count = 15,
        support_tickets = 1,
        feature_adoption = 5
      )
    ),
    built_by = "Taskomation",
    website = "https://taskomation.com"
  )
}
