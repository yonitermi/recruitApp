from flask import request, redirect, url_for, render_template
from . import app, db
from .models import Recruiter

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        recruiter = Recruiter(
            name=request.form['name'],
            company=request.form['company'],
            phone=request.form['phone'],
            email=request.form['email'],
            message=request.form['message']
        )
        db.session.add(recruiter)
        db.session.commit()
        return redirect(url_for('thank_you'))
    
    return render_template('index.html')

@app.route('/thank-you')
def thank_you():
    return render_template('thank_you.html')
