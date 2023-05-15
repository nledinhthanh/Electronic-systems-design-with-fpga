LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY xtea_top_duplex IS
    PORT (
        clk                 : IN  STD_LOGIC;
        reset_n             : IN  STD_LOGIC;
        data_word_in        : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        data_valid          : IN  STD_LOGIC;
        ciphertext_word_in  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        ciphertext_valid    : IN  STD_LOGIC;
        key_word_in         : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        key_valid           : IN  STD_LOGIC;
        key_ready           : OUT STD_LOGIC;
        ciphertext_word_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        ciphertext_ready    : OUT STD_LOGIC;
        data_word_out       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        data_ready          : OUT STD_LOGIC
    );
END ENTITY xtea_top_duplex;

ARCHITECTURE rtl OF xtea_top_duplex IS
    SIGNAL key_ready_int      : STD_LOGIC;
    SIGNAL ciphertext_ready_int : STD_LOGIC;
    SIGNAL data_ready_int     : STD_LOGIC;
    SIGNAL round_done         : STD_LOGIC;

    COMPONENT xtea_core
        PORT (
            clk                 : IN  STD_LOGIC;
            reset_n             : IN  STD_LOGIC;
            data_word_in        : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            data_valid          : IN  STD_LOGIC;
            ciphertext_word_in  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            ciphertext_valid    : IN  STD_LOGIC;
            key_word_in         : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            key_valid           : IN  STD_LOGIC;
            key_ready           : OUT STD_LOGIC;
            ciphertext_word_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            ciphertext_ready    : OUT STD_LOGIC;
            data_word_out       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            data_ready          : OUT STD_LOGIC;
            round_done          : OUT STD_LOGIC
        );
    END COMPONENT xtea_core;

    FUNCTION xtea_encrypt(
        data_in     : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        key         : IN STD_LOGIC_VECTOR(31 DOWNTO 0)
    ) RETURN STD_LOGIC_VECTOR IS
        VARIABLE result : STD_LOGIC_VECTOR(31 DOWNTO 0);
        VARIABLE sum    : STD_LOGIC_VECTOR(31 DOWNTO 0);
        VARIABLE delta  : STD_LOGIC_VECTOR(31 DOWNTO 0);
        VARIABLE y      : STD_LOGIC_VECTOR(31 DOWNTO 0);
        VARIABLE z      : STD_LOGIC_VECTOR(31 DOWNTO 0);
        VARIABLE k      : STD_LOGIC_VECTOR(127 DOWNTO 0);
        VARIABLE i      : INTEGER;
    BEGIN
        sum := (OTHERS => '0');
        delta := x"9E3779B9";
        y := data_in(31 DOWNTO 0);
        z := data_in(63 DOWNTO 32);
        k := key;

        FOR i IN 0 TO 31 LOOP
            z := z + ((y << 4) XOR (y >> 5)) + y XOR sum + k(i AND 3);
            sum := sum + delta;
            y := y + ((z << 4) XOR (z
        >> 5)) + z XOR sum + k((sum >> 11) AND 3);
        END LOOP;

        result := z & y; -- Concatenate z and y to form the result

        RETURN result;
    END FUNCTION xtea_encrypt;

    FUNCTION xtea_decrypt(
        data_in     : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        key         : IN STD_LOGIC_VECTOR(31 DOWNTO 0)
    ) RETURN STD_LOGIC_VECTOR IS
        VARIABLE result : STD_LOGIC_VECTOR(31 DOWNTO 0);
        VARIABLE sum    : STD_LOGIC_VECTOR(31 DOWNTO 0);
        VARIABLE delta  : STD_LOGIC_VECTOR(31 DOWNTO 0);
        VARIABLE y      : STD_LOGIC_VECTOR(31 DOWNTO 0);
        VARIABLE z      : STD_LOGIC_VECTOR(31 DOWNTO 0);
        VARIABLE k      : STD_LOGIC_VECTOR(127 DOWNTO 0);
        VARIABLE i      : INTEGER;
    BEGIN
        sum := x"C6EF3720";
        delta := x"9E3779B9";
        y := data_in(31 DOWNTO 0);
        z := data_in(63 DOWNTO 32);
        k := key;

        FOR i IN REVERSE 0 TO 31 LOOP
            z := z - ((y << 4) XOR (y >> 5)) + y XOR sum + k((sum >> 11) AND 3);
            sum := sum - delta;
            y := y - ((z << 4) XOR (z >> 5)) + z XOR sum + k(i AND 3);
        END LOOP;

        result := z & y; -- Concatenate z and y to form the result

        RETURN result;
    END FUNCTION xtea_decrypt;

BEGIN
    -- Instantiate XTEA core
    xtea_inst : xtea_core
    PORT MAP (
        clk                 => clk,
        reset_n             => reset_n,
        data_word_in        => data_word_in,
        data_valid          => data_valid,
        ciphertext_word_in  => ciphertext_word_in,
        ciphertext_valid    => ciphertext_valid,
        key_word_in         => key_word_in,
        key_valid           => key_valid,
        key_ready           => key_ready_int,
        ciphertext_word_out => ciphertext_word_out,
        ciphertext_ready    => ciphertext_ready_int,
        data_word_out       => data_word_out,
        data_ready          => data_ready_int,
        round_done          => round_done
    );

    -- Key ready
    key_ready <= key_ready_int;

    -- Ciphertext ready
    ciphertext_ready <= ciphertext_ready_int;

    -- Data ready
    data_ready <= data_ready_int;

END ARCHITECTURE rtl;

  
