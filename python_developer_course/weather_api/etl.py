import os
import pandas as pd


def clean_temperature_data(directory):
    """
    Cleans temperature data files located in the specified directory.
    
    Parameters:
    - directory (str): Path to the directory containing temperature data files.
    
    Returns:
    - pandas.DataFrame: Cleaned temperature data.
    
    This function reads each file in the specified directory, filters out relevant columns,
    converts temperature values from Celsius to Fahrenheit, and writes the cleaned data to a CSV file.
    """

    # initialize an empty list to store individual DataFrames
    dfs = []
    
    # iterate through each file in the directory
    for filename in os.listdir(directory):

        # check if the file name starts with 'TG_STAID'
        if filename.startswith("TG_STAID"):
            filepath = os.path.join(directory, filename)  # get the full file path

            with open(filepath, 'r') as file:
                # read file content and skip initial rows
                temp_df = pd.read_csv(filepath, skiprows=20)
                # append the DataFrame to the list
                dfs.append(temp_df)

    # concatenate all DataFrames into a single DataFrame
    data = pd.concat(dfs, ignore_index=True)

    # filter and rename columns
    data = data[['STAID', '    DATE', '   TG']]
    data.columns = ['station_id', 'date', 'temp_c']

    # apply transformation: division by 10 to convert temperature from tenths of Celsius to Celsius
    data['temp_c'] = data['temp_c'] / 10

    # calculate temperature in Fahrenheit and add as a new column
    data['temp_f'] = data['temp_c'] * (9/5) + 32

    # write cleaned DataFrame to a CSV file
    data.to_csv('data/cleaned.csv', index=False)

    return data


cleaned_data = clean_temperature_data('data')