# -*- coding: utf-8 -*-
"""
Created on 16 Apr 2025

@author: Junfeng Li (https://github.com/MarveenLee), Qinghong Lai
"""

import numpy as np
from scipy.optimize import linear_sum_assignment
from sklearn.metrics import confusion_matrix, adjusted_rand_score, adjusted_mutual_info_score
import time
import os
from openpyxl import load_workbook

dataset_name = 'DryBean'
algorithm_name = 'GBSK'
# Path to the main directory containing result folders
clutering_results_dir = r"D:\experiment outcomes"
main_dir = os.path.join(os.path.join(clutering_results_dir, algorithm_name), dataset_name)
records_table_path = r'D:\experiment records\GBSK run records.xlsx'
# Path to the groundtruth labels file (change as necessary)
labels2_path = r'D:\Datasets\DryBean\labels.txt'

# Function to check if 'AMI' is present in the last line of log.txt
def check_ami_in_log(log_path):
    with open(log_path, 'r') as file:
        last_line = file.readlines()[-1].strip()
        return 'AMI' in last_line

# Function to find the row based on the seed in column F
def find_seed_row(sheet, seed):
    for row in range(2, sheet.max_row + 1):  # Start from row 2 to skip header
        cell_value = sheet.cell(row=row, column=6).value  # Column F (Seed column)
        if cell_value == int(seed):
            return row
    return None  # Return None if seed is not found

# Loop through all folders in the main directory
for folder_name in os.listdir(main_dir):
    folder_path = os.path.join(main_dir, folder_name)

    # Ensure it's a directory
    if os.path.isdir(folder_path):
        labels_file = os.path.join(folder_path, 'labels.txt')
        if not os.path.exists(labels_file):
            # print(f"Skipping {folder_name} as labels.txt does not exist.")
            try:
                # Delete the folder and its contents
                import shutil
                shutil.rmtree(folder_path)
                print(f"Deleted folder {folder_path} as labels.txt was missing.")
            except Exception as e:
                print(f"Failed to delete folder {folder_path}: {e}")
            continue
        log_file = os.path.join(folder_path, 'log.txt')
        if not os.path.exists(log_file):
            print(f"Skipping {folder_name} as log.txt does not exist.")
            continue

        # Extract the seed from the folder name
        seed = folder_name.split(' ')[0].replace('Seed_', '')  # Get seed from folder name, e.g., 2027204734

        # Check if the log.txt contains "AMI" in the last line
        if check_ami_in_log(log_file):
            print(f"Skipping {folder_name} as it has already been evaluated quality.")
            continue

        # If not, compute ACC, ARI, and AMI

        # Load the labels
        labels1 = np.loadtxt(labels_file)
        labels2 = np.loadtxt(labels2_path)

        # Start timing for accuracy computation
        start_accuracy = time.time()

        # Compute confusion matrix
        cm = confusion_matrix(labels1, labels2)

        # Use the Hungarian algorithm to find the optimal matching
        row_ind, col_ind = linear_sum_assignment(cm, maximize=True)

        # Compute accuracy
        accuracy = cm[row_ind, col_ind].sum() / np.sum(cm)
        print(f"ACC for {folder_name}: {accuracy:.4f}")

        # End timing for accuracy computation
        elapsed_accuracy = time.time() - start_accuracy
        print(f"Time taken for accuracy computation: {elapsed_accuracy:.2f} seconds")

        # Start timing for ARI computation
        start_ari = time.time()

        # Compute ARI
        ari = adjusted_rand_score(labels1, labels2)
        print(f"ARI for {folder_name}: {ari:.4f}")

        # End timing for ARI computation
        elapsed_ari = time.time() - start_ari
        print(f"Time taken for ARI computation: {elapsed_ari:.2f} seconds")

        # Start timing for AMI computation
        start_ami = time.time()

        # Compute AMI
        ami = adjusted_mutual_info_score(labels1, labels2)
        print(f"AMI for {folder_name}: {ami:.4f}")

        # End timing for AMI computation
        elapsed_ami = time.time() - start_ami
        print(f"Time taken for AMI computation: {elapsed_ami:.2f} seconds")

        # Now, write results to the Excel file 
        # Load the existing Excel file
        wb = load_workbook(records_table_path)
        sheet = wb[dataset_name]

        # Find the row corresponding to the seed in column F
        seed_row = find_seed_row(sheet, seed)

        if seed_row is not None:
            # Write the results for ACC, ARI, AMI to the corresponding row
            sheet.cell(row=seed_row, column=18, value=accuracy)  # Column R for ACC
            sheet.cell(row=seed_row, column=19, value=ari)      # Column S for ARI
            sheet.cell(row=seed_row, column=20, value=ami)      # Column T for AMI
            print(f"Results for {folder_name} written to row {seed_row}.")
        else:
            print(f"Seed {seed} not found in Excel. Skipping write operation.")

        # Save the Excel file
        wb.save(records_table_path)

        # Write ACC, ARI, and AMI to the tail of the log.txt
        with open(log_file, 'a') as log:
            log.write(f"ACC: {accuracy:.4f}\n")
            log.write(f"ARI: {ari:.4f}\n")
            log.write(f"AMI: {ami:.4f}\n")

        print(f"Results for {folder_name} written to log.txt.")

# Delete workbook reference to release file handle
del wb
del sheet

# Force garbage collection
import gc
gc.collect()