# ChurnShield API

R-powered churn risk scoring API for Taskomation.

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/` | API info and documentation |
| GET | `/health` | Health check |
| POST | `/score` | Calculate health score from metrics |
| GET | `/demo-customers` | View demo customer data |

## Deploy to Render

1. **Create new Web Service on Render**
   - Go to https://dashboard.render.com
   - Click "New" → "Web Service"
   - Connect this repo or upload files

2. **Configure:**
   - Name: `churnshield-api`
   - Environment: `Docker`
   - Plan: `Free` (for demo) or `Standard` ($25/mo for production)

3. **Deploy**
   - Render will build from Dockerfile
   - Takes ~3-5 minutes first time

## Test Locally

```bash
# Install R and plumber first
R -e "install.packages('plumber')"

# Run the API
R -e "plumber::plumb('plumber.R')$run(port=8080)"

# Test
curl http://localhost:8080/health
curl -X POST http://localhost:8080/score \
  -H "Content-Type: application/json" \
  -d '{"days_inactive": 14, "login_count": 5, "support_tickets": 2, "feature_adoption": 3}'
```

## Example Response

```json
{
  "health_score": 52.5,
  "risk_level": "MEDIUM",
  "churn_probability": 0.48,
  "estimated_days_to_churn": 248,
  "recommendations": [
    "Send re-engagement email",
    "Schedule customer success call"
  ]
}
```

## Built With

- R 4.3.0
- Plumber (R web framework)
- Docker
- Render.com

---

*Part of Taskomation - https://taskomation.com*
