FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire project directory into the container
COPY . /app

# Expose the port the app runs on
EXPOSE 5000

# Set the command to run the application using run.py
CMD ["python", "run.py"]
