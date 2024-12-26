# Base Converter in MIPS Assembly

This MIPS assembly program converts a number from one base to another. It reads a number and its base from the user, validates the input, converts the number to decimal, and then converts it to a new base specified by the user.

## Features

- **Input Validation**: Ensures the number is valid for the given base.
- **Base Conversion**: Converts numbers from any base (up to 36) to decimal and then to another base.
- **User Interaction**: Prompts the user for input and displays the result.

## How It Works

1. **User Input**: The program prompts the user to enter a number and its base.
2. **Validation**: The `isValid` function checks if the number is valid for the specified base.
3. **Conversion to Decimal**: The `otherToDec` function converts the valid number from its base to a decimal integer.
4. **Conversion to New Base**: The `decimal_to_other` function converts the decimal number to the new base specified by the user.
5. **Output**: The program displays the converted number in the new base.

## Program Structure

- **Data Section**: Defines storage for input strings, bases, results, and prompts.
- **Text Section**: Contains the main program logic and functions for validation and conversion.

### Key Functions

- **`isValid`**: Validates the input number against its base.
- **`otherToDec`**: Converts a number from a specified base to decimal.
- **`decimal_to_other`**: Converts a decimal number to a specified base.

## Usage

1. Assemble and run the program using a MIPS simulator like MARS or SPIM.
2. Follow the prompts to enter a number, its base, and the new base.
3. View the converted number in the new base.
