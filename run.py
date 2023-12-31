import os

from app import app, db

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(host='0.0.0.0', port=int(os.environ.get('FLASKAPP_PORT', 5000)), debug=True)
