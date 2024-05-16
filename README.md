# Temperature Monitoring Application

This repository contains a Temperature Monitoring Application developed using Elixir and the Phoenix framework. The application handles thousands of temperature values from sensors and displays them on a user interface (UI) in real-time.

## Overview

This application demonstrates the use of Elixir's GenServer for sensor simulation, Phoenix Channels for real-time communication, and WebSocket for data transport. The client-side JavaScript dynamically updates the UI, ensuring real-time reflection of temperature changes. The use of color coding enhances the visual representation of temperature variations, making the data easily interpretable for users.

## Architecture and Data Flow

### Components

1. **Temperature Sensors**: Simulated sensors generating temperature data.
2. **GenServer (Elixir)**: Manages sensor state and updates.
3. **Phoenix Channels**: Facilitates real-time communication between the server and the client.
4. **WebSocket**: Transports data between the server and the client.
5. **JavaScript**: Updates the UI based on the received data.

### Data Flow

1. **Sensor Initialization**: 
    - The application initializes 5000 simulated temperature sensors when it starts. Each sensor is managed by a GenServer, which periodically updates its temperature and broadcasts this data.

2. **Temperature Update and Broadcasting**:
    - Each sensor updates its temperature value at regular intervals and broadcasts this new value to the "temperature:lobby" channel using Phoenix PubSub.

3. **Channel Communication**:
    - The `TemperatureChannel` module handles the real-time data broadcast to connected clients. Clients join the "temperature:lobby" channel, where they receive updates on new temperature readings.

4. **WebSocket Transport**:
    - The application uses WebSocket for communication between the server and the client, ensuring low-latency and real-time updates.

5. **Client-Side Processing**:
    - The client-side JavaScript listens for incoming temperature data and updates the DOM to reflect the new values.

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

## Diagrams

### 1. Architecture Overview

![Architecture Overview](https://via.placeholder.com/600x400.png?text=Architecture+Overview)

**Description**: This diagram illustrates the overall architecture of the application, showing the main components and their interactions.

- **Temperature Sensors (GenServer)**: Simulated sensors managed by GenServers.
- **Phoenix PubSub**: Broadcasts temperature updates.
- **Temperature Channel**: Manages real-time communication with clients.
- **WebSocket**: Facilitates the connection between the server and the client.
- **Client (JavaScript)**: Receives updates and modifies the DOM.

### 2. Data Flow Diagram

![Data Flow Diagram](https://via.placeholder.com/600x400.png?text=Data+Flow+Diagram)

**Description**: This diagram details the flow of data from sensors to the client UI.

1. **Sensor Initialization**:
    - The application initializes 5000 sensors.
2. **Temperature Update**:
    - Sensors periodically update their temperatures and broadcast the new values.
3. **Phoenix PubSub**:
    - The updated temperatures are sent to the "temperature:lobby" channel.
4. **Temperature Channel**:
    - The channel collects temperature updates in a buffer and periodically broadcasts them to connected clients.
5. **WebSocket Communication**:
    - Clients receive the temperature updates over WebSocket.
6. **DOM Update**:
    - The client-side JavaScript updates the UI with the new temperature data and recalculates the cell colors.

### 3. Client-Side Update Mechanism

![Client-Side Update Mechanism](https://via.placeholder.com/600x400.png?text=Client-Side+Update+Mechanism)

**Description**: This diagram focuses on the client-side process of updating the DOM based on received temperature data.

1. **Connection Establishment**:
    - The client connects to the server via WebSocket.
2. **Data Reception**:
    - The client receives temperature updates from the "temperature:lobby" channel.
3. **DOM Update**:
    - The JavaScript function `updateUI` updates the table cells with the new temperature values.
4. **Color Calculation**:
    - The function `getColorForTemperature` calculates the cell colors based on temperature values.

## Summary

This application effectively demonstrates the use of Elixir's GenServer for sensor simulation, Phoenix Channels for real-time communication, and WebSocket for data transport. The client-side JavaScript dynamically updates the UI, ensuring real-time reflection of temperature changes. The use of color coding enhances the visual representation of temperature variations, making the data easily interpretable for users.
