from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
from datetime import timedelta

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///finance_tracker.db'
db = SQLAlchemy(app)

class Transaction(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    amount = db.Column(db.Float, nullable=False)
    category = db.Column(db.String(100), nullable=False)
    date = db.Column(db.String, default=datetime.today().strftime("%-d/%-m/%y")  )

@app.route('/transactions', methods=['POST','GET'])
def add_transaction():
    data = request.json
    print(data)
    new_transaction = Transaction(
        amount=data['amount'],
        category=data['category'],
    )
    db.session.add(new_transaction)
    print("ended")
    db.session.commit()
    
    return jsonify({'message': 'Transaction added successfully'}), 201


@app.route('/transaction_ids', methods=['GET'])
def get_transaction_ids():
    transaction_ids = [transaction.id for transaction in Transaction.query.all()]
    return jsonify(transaction_ids)

@app.route('/transaction/<int:transaction_id>', methods=['GET'])
def get_transaction(transaction_id):
    
    transaction = Transaction.query.get(transaction_id)
    if transaction is None:
        return jsonify({'message': 'Transaction not found'}), 404
    
    return jsonify({
        'id': transaction.id,
        'amount': transaction.amount,
        'name': transaction.category,
        'date': transaction.date,
    })

@app.route('/', methods=['GET'])
def get_transactions():
    transactions = Transaction.query.all()
    return jsonify([{
        'id': t.id,
        'amount': t.amount,
        'category': t.category,
        'date': t.date,
    } for t in transactions])


@app.route('/monthly_weekly_budget', methods=['GET'])
def get_monthly_weekly_budget():
    today = datetime.now()
    month=today.strftime("%-m")
    year=today.strftime("%y")
    last_week = today - timedelta(days=7)
    transactions = Transaction.query.filter(
        Transaction.date >= last_week.strftime("%-d/%-m/%y"),
    ).all()
    weekly_budget = sum(transaction.amount for transaction in transactions)
    expenses = Transaction.query.filter(
        Transaction.date.like(f'%/{month}/{year}'),
    ).all()
    
    total_expenses = sum(expense.amount for expense in expenses)
    return jsonify({'month_expenses': total_expenses
                    ,'weekly_expenses': weekly_budget})

if __name__ == '__main__':
    
    with app.app_context():
        db.create_all()
    app.run(debug=True)
