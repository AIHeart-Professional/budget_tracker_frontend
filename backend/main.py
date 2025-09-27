"""
Budget Tracker Backend API
FastAPI server for managing budget data
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime, date
import sqlite3
import json
import os

app = FastAPI(title="Budget Tracker API", version="1.0.0")

# Enable CORS for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Database setup
DATABASE_PATH = "budget_tracker.db"

def init_database():
    """Initialize SQLite database with required tables"""
    conn = sqlite3.connect(DATABASE_PATH)
    cursor = conn.cursor()
    
    # Transactions table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            category TEXT NOT NULL,
            type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
            date TEXT NOT NULL,
            time TEXT NOT NULL,
            description TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    # Categories table
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE,
            type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
            budget REAL DEFAULT 0,
            icon TEXT DEFAULT 'category',
            color TEXT DEFAULT '#2196F3',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    # Insert default categories
    default_categories = [
        ('Food & Dining', 'expense', 600.0, 'restaurant', '#FF9800'),
        ('Transportation', 'expense', 400.0, 'directions_car', '#2196F3'),
        ('Shopping', 'expense', 350.0, 'shopping_bag', '#9C27B0'),
        ('Entertainment', 'expense', 200.0, 'movie', '#009688'),
        ('Health', 'expense', 300.0, 'medical_services', '#F44336'),
        ('Education', 'expense', 250.0, 'school', '#3F51B5'),
        ('Utilities', 'expense', 500.0, 'electrical_services', '#FFC107'),
        ('Rent', 'expense', 1200.0, 'home', '#795548'),
        ('Salary', 'income', 0.0, 'work', '#4CAF50'),
        ('Freelance', 'income', 0.0, 'laptop', '#2196F3'),
        ('Business', 'income', 0.0, 'business', '#9C27B0'),
        ('Investment', 'income', 0.0, 'trending_up', '#009688'),
    ]
    
    for category in default_categories:
        cursor.execute('''
            INSERT OR IGNORE INTO categories (name, type, budget, icon, color) 
            VALUES (?, ?, ?, ?, ?)
        ''', category)
    
    conn.commit()
    conn.close()

# Pydantic models
class TransactionCreate(BaseModel):
    title: str
    amount: float
    category: str
    type: str  # 'income' or 'expense'
    date: str
    time: str
    description: Optional[str] = None

class Transaction(TransactionCreate):
    id: int
    created_at: str

class CategoryCreate(BaseModel):
    name: str
    type: str  # 'income' or 'expense'
    budget: float = 0.0
    icon: str = 'category'
    color: str = '#2196F3'

class Category(CategoryCreate):
    id: int
    created_at: str

class BudgetSummary(BaseModel):
    total_income: float
    total_expenses: float
    balance: float
    budget_used: float
    budget_remaining: float

# Initialize database on startup
@app.on_event("startup")
async def startup_event():
    init_database()

# Health check endpoint
@app.get("/")
async def root():
    return {"message": "Budget Tracker API is running", "version": "1.0.0"}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "timestamp": datetime.now().isoformat()}

# Transaction endpoints
@app.get("/transactions", response_model=List[Transaction])
async def get_transactions(
    type: Optional[str] = None,
    category: Optional[str] = None,
    limit: Optional[int] = 100
):
    """Get all transactions with optional filtering"""
    conn = sqlite3.connect(DATABASE_PATH)
    cursor = conn.cursor()
    
    query = "SELECT * FROM transactions WHERE 1=1"
    params = []
    
    if type:
        query += " AND type = ?"
        params.append(type)
    
    if category:
        query += " AND category = ?"
        params.append(category)
    
    query += " ORDER BY date DESC, time DESC LIMIT ?"
    params.append(limit)
    
    cursor.execute(query, params)
    rows = cursor.fetchall()
    conn.close()
    
    transactions = []
    for row in rows:
        transactions.append(Transaction(
            id=row[0],
            title=row[1],
            amount=row[2],
            category=row[3],
            type=row[4],
            date=row[5],
            time=row[6],
            description=row[7],
            created_at=row[8]
        ))
    
    return transactions

@app.post("/transactions", response_model=Transaction)
async def create_transaction(transaction: TransactionCreate):
    """Create a new transaction"""
    conn = sqlite3.connect(DATABASE_PATH)
    cursor = conn.cursor()
    
    cursor.execute('''
        INSERT INTO transactions (title, amount, category, type, date, time, description)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ''', (
        transaction.title,
        transaction.amount,
        transaction.category,
        transaction.type,
        transaction.date,
        transaction.time,
        transaction.description
    ))
    
    transaction_id = cursor.lastrowid
    conn.commit()
    conn.close()
    
    # Return the created transaction
    return Transaction(
        id=transaction_id,
        title=transaction.title,
        amount=transaction.amount,
        category=transaction.category,
        type=transaction.type,
        date=transaction.date,
        time=transaction.time,
        description=transaction.description,
        created_at=datetime.now().isoformat()
    )

@app.get("/transactions/{transaction_id}", response_model=Transaction)
async def get_transaction(transaction_id: int):
    """Get a specific transaction by ID"""
    conn = sqlite3.connect(DATABASE_PATH)
    cursor = conn.cursor()
    
    cursor.execute("SELECT * FROM transactions WHERE id = ?", (transaction_id,))
    row = cursor.fetchone()
    conn.close()
    
    if not row:
        raise HTTPException(status_code=404, detail="Transaction not found")
    
    return Transaction(
        id=row[0],
        title=row[1],
        amount=row[2],
        category=row[3],
        type=row[4],
        date=row[5],
        time=row[6],
        description=row[7],
        created_at=row[8]
    )

@app.delete("/transactions/{transaction_id}")
async def delete_transaction(transaction_id: int):
    """Delete a transaction"""
    conn = sqlite3.connect(DATABASE_PATH)
    cursor = conn.cursor()
    
    cursor.execute("DELETE FROM transactions WHERE id = ?", (transaction_id,))
    
    if cursor.rowcount == 0:
        conn.close()
        raise HTTPException(status_code=404, detail="Transaction not found")
    
    conn.commit()
    conn.close()
    
    return {"message": "Transaction deleted successfully"}

# Category endpoints
@app.get("/categories", response_model=List[Category])
async def get_categories(type: Optional[str] = None):
    """Get all categories with optional type filtering"""
    conn = sqlite3.connect(DATABASE_PATH)
    cursor = conn.cursor()
    
    if type:
        cursor.execute("SELECT * FROM categories WHERE type = ? ORDER BY name", (type,))
    else:
        cursor.execute("SELECT * FROM categories ORDER BY name")
    
    rows = cursor.fetchall()
    conn.close()
    
    categories = []
    for row in rows:
        categories.append(Category(
            id=row[0],
            name=row[1],
            type=row[2],
            budget=row[3],
            icon=row[4],
            color=row[5],
            created_at=row[6]
        ))
    
    return categories

@app.post("/categories", response_model=Category)
async def create_category(category: CategoryCreate):
    """Create a new category"""
    conn = sqlite3.connect(DATABASE_PATH)
    cursor = conn.cursor()
    
    try:
        cursor.execute('''
            INSERT INTO categories (name, type, budget, icon, color)
            VALUES (?, ?, ?, ?, ?)
        ''', (
            category.name,
            category.type,
            category.budget,
            category.icon,
            category.color
        ))
        
        category_id = cursor.lastrowid
        conn.commit()
        conn.close()
        
        return Category(
            id=category_id,
            name=category.name,
            type=category.type,
            budget=category.budget,
            icon=category.icon,
            color=category.color,
            created_at=datetime.now().isoformat()
        )
    
    except sqlite3.IntegrityError:
        conn.close()
        raise HTTPException(status_code=400, detail="Category already exists")

# Budget summary endpoint
@app.get("/budget/summary", response_model=BudgetSummary)
async def get_budget_summary():
    """Get budget summary with income, expenses, and balance"""
    conn = sqlite3.connect(DATABASE_PATH)
    cursor = conn.cursor()
    
    # Get total income
    cursor.execute("SELECT COALESCE(SUM(amount), 0) FROM transactions WHERE type = 'income'")
    total_income = cursor.fetchone()[0]
    
    # Get total expenses
    cursor.execute("SELECT COALESCE(SUM(amount), 0) FROM transactions WHERE type = 'expense'")
    total_expenses = cursor.fetchone()[0]
    
    # Get total budget from categories
    cursor.execute("SELECT COALESCE(SUM(budget), 0) FROM categories WHERE type = 'expense'")
    total_budget = cursor.fetchone()[0]
    
    conn.close()
    
    balance = total_income - total_expenses
    budget_remaining = total_budget - total_expenses
    
    return BudgetSummary(
        total_income=total_income,
        total_expenses=total_expenses,
        balance=balance,
        budget_used=total_expenses,
        budget_remaining=budget_remaining
    )

# Category spending analysis
@app.get("/budget/categories")
async def get_category_spending():
    """Get spending analysis by category"""
    conn = sqlite3.connect(DATABASE_PATH)
    cursor = conn.cursor()
    
    cursor.execute('''
        SELECT 
            c.name,
            c.budget,
            c.icon,
            c.color,
            COALESCE(SUM(t.amount), 0) as spent
        FROM categories c
        LEFT JOIN transactions t ON c.name = t.category AND t.type = 'expense'
        WHERE c.type = 'expense'
        GROUP BY c.id, c.name, c.budget, c.icon, c.color
        ORDER BY spent DESC
    ''')
    
    rows = cursor.fetchall()
    conn.close()
    
    categories = []
    for row in rows:
        categories.append({
            'name': row[0],
            'budget': row[1],
            'icon': row[2],
            'color': row[3],
            'spent': row[4],
            'remaining': row[1] - row[4],
            'percentage': (row[4] / row[1] * 100) if row[1] > 0 else 0
        })
    
    return categories

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000, log_level="info")
