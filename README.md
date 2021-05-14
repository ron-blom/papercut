# Build image:

docker image build --no-cache -t blomron/papercut .

# Run container interactive:

docker container run -p 9163:9163 -v /Users/rblom/papercut:/home/papercut/pc-mobility-print/data/config -it blomron/papercut bash

# Push image:


# Custom add-ons:

dumb-init_1.2.5_x86_64: https://github.com/Yelp/dumb-init

