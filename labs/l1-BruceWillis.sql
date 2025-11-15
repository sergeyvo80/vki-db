SELECT Company.name FROM Company
JOIN Passenger ON Passenger.name='Bruce Willis'
JOIN Pass_in_trip ON Pass_in_trip.passenger=Passenger.id
JOIN Trip ON Trip.id=Pass_in_trip.Trip AND Trip.company=Company.id;
