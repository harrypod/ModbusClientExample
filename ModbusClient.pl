#!/usr/bin/perl

use Data::Dumper;
use Device::Modbus;
use Device::Modbus::RTU::Client;


sub hex_array($)
{
    ### HEX ARRAY RETURNS an array FROM a passed HEX string
    ### THe HEX String will be pairs of HEX Values 
    ### such as 1F2DX1 will result in @arr['1F','2D','X1']
    my $hex=shift;          ## the main data string
    my $len = length($hex);
    my $start=0;
    my @returned_hex;
    my ($hex_val);
    while ($start < $len)           ### PUT HEX values into array
    {
        # first 2 chars
        $hex_val = substr ($hex,$start,2) ;
        $start +=2;
        push(@returned_hex,$hex_val);
    }
    return @returned_hex;
}

sub return_ascii(@) { 
    my @in = @_;
    my $ascii = join "", map((sprintf "%c",hex($_)), hex_array(join "",map { (sprintf "%02x",$_) } @in));
    return $ascii;
    ## 1. Hex each element
    ## 2. Split element into bytes
    ## 3. convert each byte into char
    ## 4. join all results in one string
}


my $address = 256;      # Address of Modbus Field
my $registers = 16;     # Register holding fields

my $dev_connect = Device::Modbus::RTU::Client->new(
	port => "/dev/ttyUSB1",
	baudrate =>  19200,
        parity   => 'none',
);               
   
eval{
    my $request = $dev_connect->read_holding_registers(
                        unit     => 3,
                        address  => $address,         ## Field Address
                        quantity => $registers,       ## Qty
                    );

    $dev_connect->send_request($request);
            my $response = $dev_connect->receive_response;
    $result = return_ascii(@{$response->{'message'}{'values'}});


    print "RESULT: $result\n";

print Dumper($response);
};
if($@) { 
    print "Could not connect!\n";
}