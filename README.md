# Temperature Monitoring Application

## Overview

This documentation provides a comprehensive overview of the Temperature Monitoring Application developed using Elixir and the Phoenix framework. The application handles thousands of temperature values from sensors and displays them on a user interface (UI) in real-time. This document covers the flow of data, the handling of WebSocket communication, and the mechanism for updating the UI.

## Architecture and Data Flow

### Components

- **Temperature Sensors**: Simulated sensors generating temperature data.
- **GenServer (Elixir)**: Manages sensor state and updates.
- **Phoenix Channels**: Facilitates real-time communication between the server and the client.
- **WebSocket**: Transports data between the server and the client.
- **JavaScript**: Updates the UI based on the received data.

### Data Flow

#### Sensor Initialization

The application initializes 5000 simulated temperature sensors when it starts. Each sensor is managed by a GenServer, which periodically updates its temperature and broadcasts this data.

#### Temperature Update and Broadcasting

Each sensor updates its temperature value at regular intervals and broadcasts this new value to the "temperature:lobby" channel using Phoenix PubSub.

#### Channel Communication

The `TemperatureChannel` module handles the real-time data broadcast to connected clients. Clients join the "temperature:lobby" channel, where they receive updates on new temperature readings.

#### WebSocket Transport

The application uses WebSocket for communication between the server and the client, ensuring low-latency and real-time updates.

#### Client-Side Processing

The client-side JavaScript listens for incoming temperature data and updates the DOM to reflect the new values.

## Detailed Component Interaction

### GenServer (Elixir)

- **Initialization**: Each sensor is initialized with a random temperature, a rate of change, and a temperature range.
- **Temperature Update**: The GenServer periodically updates the temperature based on the rate and reverses the rate when the temperature reaches the defined limits.
- **Broadcasting**: After updating, the new temperature is broadcasted to the "temperature:lobby" channel.

### Phoenix Channels

- **Joining the Channel**: When a client connects, it joins the "temperature:lobby" channel, receiving a confirmation or error message.
- **Receiving Data**: The `handle_info/2` function processes incoming temperature data and updates a buffer.
- **Broadcasting Data**: At regular intervals, the buffered data is broadcasted to all clients connected to the channel.

### WebSocket Communication

- **Setup**: The client sets up a WebSocket connection using the Phoenix Socket.
- **Message Handling**: The client listens for the "new_temperatures" event to receive temperature updates.

### Client-Side DOM Updates

- **Initialization**: When the page loads, a table is created to display sensor data.
- **Receiving Updates**: The client processes the incoming data and updates the respective table cells.
- **Color Calculation**: The background color of each cell is determined by the temperature value. A hue-based color mapping is used, with blue representing lower temperatures and red representing higher temperatures.

## Technical Details

### WebSocket Communication

- **Protocol**: WebSocket
- **Channel**: "temperature:lobby"
- **Events**:
  - `"new_temperatures"`: Sent from the server with the latest temperature readings.

### DOM Updates

- **Table Structure**: The UI contains a table with cells representing individual sensors.
- **Data Binding**: Each cell is identified by a unique ID corresponding to the sensor ID.
- **Temperature Display**: The temperature value is displayed inside the cell.
- **Color Calculation**:
  - Temperature values are normalized within a predefined range.
  - The normalized value is mapped to a color spectrum using HSL (Hue, Saturation, Lightness).
  - Lower temperatures are mapped to blue hues, and higher temperatures to red hues.

### Functions and Methods

- **GenServer Functions**: `start_link/1`, `init/1`, `handle_info/2`, `broadcast_new_temperature/2`
- **Phoenix Channel Functions**: `join/3`, `handle_info/2`, `broadcast_temperatures/2`
- **JavaScript Functions**: `createTable`, `updateUI`, `getColorForTemperature`

## Summary

This application effectively demonstrates the use of Elixir's GenServer for sensor simulation, Phoenix Channels for real-time communication, and WebSocket for data transport. The client-side JavaScript dynamically updates the UI, ensuring real-time reflection of temperature changes. The use of color coding enhances the visual representation of temperature variations, making the data easily interpretable for users.
