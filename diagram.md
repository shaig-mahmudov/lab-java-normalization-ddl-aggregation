erDiagram

    AUTHORS {
        int author_id PK
        varchar author_name
    }
    
    ARTICLES {
        int article_id PK
        int author_id FK
        varchar title
        int word_count
        int views
    }

    AUTHORS ||--o{ ARTICLES : "writes"

    AIRCRAFTS {
        int aircraft_id PK
        varchar aircraft_model
        int total_seats
    }
    
    FLIGHTS {
        varchar flight_number PK
        int aircraft_id FK
        int flight_mileage
    }
    
    CUSTOMERS {
        int customer_id PK
        varchar customer_name
        varchar customer_status
        int total_customer_mileage
    }
    
    BOOKINGS {
        int booking_id PK
        int customer_id FK
        varchar flight_number FK
        timestamp booking_date
    }

    AIRCRAFTS ||--o{ FLIGHTS : "operates"
    CUSTOMERS ||--o{ BOOKINGS : "makes"
    FLIGHTS ||--o{ BOOKINGS : "includes"